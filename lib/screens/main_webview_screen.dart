import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class MainWebViewScreen extends StatefulWidget {
  const MainWebViewScreen({
    super.key,
  });

  @override
  State<MainWebViewScreen> createState() =>
      _MainWebViewScreenState();
}

class _MainWebViewScreenState extends State<MainWebViewScreen>
    with WidgetsBindingObserver {
  static const String _homeUrl = 'https://www.ridersim.com/';

  static const Color _brandRed = Color(0xFFEE0018);
  static const Color _dark = Color(0xFF080808);
  static const Color _gray = Color(0xFF68707B);

  InAppWebViewController? _webViewController;

  late final PullToRefreshController _pullToRefreshController;
  late final InternetConnection _internetConnection;

  StreamSubscription<InternetStatus>? _internetSubscription;

  Timer? _pageTimeoutTimer;

  bool _isOffline = false;
  bool _initialPageVisible = false;
  bool _hasPageError = false;
  bool _isLoading = true;
  bool _isRetrying = false;
  bool _exitDialogShowing = false;

  int _progress = 0;

  String? _errorTitle;
  String? _errorDescription;

  WebUri? _currentUrl;

  final InAppWebViewSettings _webSettings = InAppWebViewSettings(
    useShouldOverrideUrlLoading: true,
    useOnDownloadStart: true,

    javaScriptEnabled: true,
    javaScriptCanOpenWindowsAutomatically: true,

    supportMultipleWindows: true,

    thirdPartyCookiesEnabled: true,
    sharedCookiesEnabled: true,

    cacheEnabled: true,

    useWideViewPort: true,
    loadWithOverviewMode: true,

    supportZoom: false,
    builtInZoomControls: false,
    displayZoomControls: false,

    verticalScrollBarEnabled: false,
    horizontalScrollBarEnabled: false,

    allowsInlineMediaPlayback: true,
    mediaPlaybackRequiresUserGesture: true,

    hardwareAcceleration: true,

    // IMPORTANT:
    // On your TECNO device, SurfaceView/BLASTBufferQueue
    // errors were showing with Hybrid Composition.
    useHybridComposition: false,

    disableDefaultErrorPage: true,

    allowFileAccessFromFileURLs: false,
    allowUniversalAccessFromFileURLs: false,

    preferredContentMode: UserPreferredContentMode.MOBILE,

    transparentBackground: false,
    underPageBackgroundColor: Colors.white,
  );

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addObserver(this);

    _setupSystemUi();

    _pullToRefreshController = PullToRefreshController(
      settings: PullToRefreshSettings(
        color: _brandRed,
        backgroundColor: Colors.white,
      ),
      onRefresh: _refreshWebView,
    );

    _internetConnection = InternetConnection.createInstance();

    // Background connectivity monitor.
    // WebView does not wait for it.
    _initialiseConnectivity();
  }

  void _setupSystemUi() {
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.edgeToEdge,
    );

    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.white,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
        systemNavigationBarColor: Colors.white,
        systemNavigationBarIconBrightness: Brightness.dark,
        systemNavigationBarDividerColor: Colors.transparent,
        systemNavigationBarContrastEnforced: false,
      ),
    );
  }

  // ============================================================
  // CONNECTIVITY
  // ============================================================

  Future<void> _initialiseConnectivity() async {
    _internetSubscription =
        _internetConnection.onStatusChange.listen(
          _handleInternetStatus,
        );

    try {
      final hasInternet =
      await _internetConnection.hasInternetAccess;

      if (!mounted) return;

      if (!hasInternet) {
        setState(() {
          _isOffline = true;
        });
      }
    } catch (_) {
      // Let WebView callbacks handle failure.
    }
  }

  void _handleInternetStatus(
      InternetStatus status,
      ) {
    if (!mounted) return;

    final connected =
        status == InternetStatus.connected;

    final wasOffline = _isOffline;

    if (connected && !_isOffline) {
      return;
    }

    if (!connected && _isOffline) {
      return;
    }

    setState(() {
      _isOffline = !connected;
    });

    if (connected && wasOffline) {
      _recoverAfterConnection();
    }
  }

  Future<void> _recoverAfterConnection() async {
    if (!mounted) return;

    setState(() {
      _hasPageError = false;
      _errorTitle = null;
      _errorDescription = null;
      _isLoading = true;
    });

    await Future<void>.delayed(
      const Duration(milliseconds: 150),
    );

    if (!mounted) return;

    await _webViewController?.reload();
  }

  // ============================================================
  // REFRESH
  // ============================================================

  Future<void> _refreshWebView() async {
    try {
      final connected =
      await _internetConnection.hasInternetAccess;

      if (!mounted) return;

      if (!connected) {
        setState(() {
          _isOffline = true;
        });

        await _pullToRefreshController.endRefreshing();

        return;
      }

      setState(() {
        _isOffline = false;
        _hasPageError = false;
        _errorTitle = null;
        _errorDescription = null;
      });

      final controller =
          _webViewController;

      if (controller != null) {
        await controller.reload();
      } else {
        await _pullToRefreshController.endRefreshing();
      }
    } catch (_) {
      await _pullToRefreshController.endRefreshing();
    }
  }

  // ============================================================
  // RETRY
  // ============================================================

  Future<void> _retry() async {
    if (_isRetrying) return;

    setState(() {
      _isRetrying = true;
    });

    try {
      final connected =
      await _internetConnection.hasInternetAccess;

      if (!mounted) return;

      if (!connected) {
        setState(() {
          _isOffline = true;
          _isRetrying = false;
        });

        return;
      }

      setState(() {
        _isOffline = false;
        _hasPageError = false;
        _errorTitle = null;
        _errorDescription = null;
        _isLoading = true;
        _isRetrying = false;
      });

      await _webViewController?.reload();
    } catch (_) {
      if (!mounted) return;

      setState(() {
        _isRetrying = false;
      });
    }
  }

  // ============================================================
  // PAGE TIMEOUT
  // ============================================================

  void _startPageTimeout() {
    _pageTimeoutTimer?.cancel();

    _pageTimeoutTimer = Timer(
      const Duration(seconds: 15),
          () {
        if (!mounted) return;

        if (_isLoading &&
            !_isOffline &&
            !_initialPageVisible) {
          setState(() {
            _hasPageError = true;
            _isLoading = false;

            _errorTitle =
            'Taking longer than expected';

            _errorDescription =
            'The page is taking too long to load. '
                'Please check your connection and try again.';
          });
        }
      },
    );
  }

  void _stopPageTimeout() {
    _pageTimeoutTimer?.cancel();
    _pageTimeoutTimer = null;
  }

  // ============================================================
  // URL HANDLING
  // ============================================================

  Future<NavigationActionPolicy> _handleNavigation(
      NavigationAction navigationAction,
      ) async {
    final webUri =
        navigationAction.request.url;

    if (webUri == null) {
      return NavigationActionPolicy.ALLOW;
    }

    final uri =
    Uri.parse(webUri.toString());

    final scheme =
    uri.scheme.toLowerCase();

    if (scheme == 'http' ||
        scheme == 'https') {
      if (_shouldOpenHttpUrlExternally(uri)) {
        await _launchExternal(uri);

        return NavigationActionPolicy.CANCEL;
      }

      return NavigationActionPolicy.ALLOW;
    }

    const externalSchemes = <String>{
      'tel',
      'mailto',
      'sms',
      'geo',
      'maps',
      'market',
      'itms-apps',
      'whatsapp',
      'intent',
    };

    if (externalSchemes.contains(scheme)) {
      await _launchExternal(uri);

      return NavigationActionPolicy.CANCEL;
    }

    if (scheme == 'about' ||
        scheme == 'javascript' ||
        scheme == 'data' ||
        scheme == 'blob') {
      return NavigationActionPolicy.ALLOW;
    }

    if (scheme.isNotEmpty) {
      await _launchExternal(uri);

      return NavigationActionPolicy.CANCEL;
    }

    return NavigationActionPolicy.ALLOW;
  }

  bool _shouldOpenHttpUrlExternally(
      Uri uri,
      ) {
    final host =
    uri.host.toLowerCase();

    if (_isRiderSimHost(host)) {
      return false;
    }

    if (_isBreezeHost(host)) {
      return false;
    }

    const externalHosts = <String>{
      'wa.me',
      'api.whatsapp.com',
      'web.whatsapp.com',

      'instagram.com',
      'www.instagram.com',

      'facebook.com',
      'www.facebook.com',
      'm.facebook.com',

      'youtube.com',
      'www.youtube.com',
      'youtu.be',

      'tiktok.com',
      'www.tiktok.com',

      'linkedin.com',
      'www.linkedin.com',

      'twitter.com',
      'www.twitter.com',

      'x.com',
      'www.x.com',

      'maps.google.com',
    };

    return externalHosts.contains(host);
  }

  bool _isRiderSimHost(
      String host,
      ) {
    return host == 'ridersim.com' ||
        host == 'www.ridersim.com' ||
        host.endsWith('.ridersim.com');
  }

  bool _isBreezeHost(
      String host,
      ) {
    return host == 'breezesim.com' ||
        host == 'www.breezesim.com' ||
        host.endsWith('.breezesim.com');
  }

  Future<void> _launchExternal(
      Uri uri,
      ) async {
    try {
      final opened =
      await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );

      if (!opened) {
        _showMessage(
          'Unable to open this link.',
        );
      }
    } catch (_) {
      _showMessage(
        'Unable to open this link.',
      );
    }
  }

  // ============================================================
  // TARGET BLANK
  // ============================================================

  Future<bool?> _handleCreateWindow(
      InAppWebViewController controller,
      CreateWindowAction action,
      ) async {
    final webUri =
        action.request.url;

    if (webUri == null) {
      return false;
    }

    final uri =
    Uri.parse(webUri.toString());

    if (uri.scheme == 'http' ||
        uri.scheme == 'https') {
      if (_shouldOpenHttpUrlExternally(uri)) {
        await _launchExternal(uri);
      } else {
        await controller.loadUrl(
          urlRequest: URLRequest(
            url: webUri,
          ),
        );
      }

      return true;
    }

    await _launchExternal(uri);

    return true;
  }

  // ============================================================
  // DOWNLOAD
  // ============================================================

  Future<void> _handleDownload(
      DownloadStartRequest request,
      ) async {
    final uri =
    Uri.parse(
      request.url.toString(),
    );

    try {
      final opened =
      await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );

      if (!opened) {
        _showMessage(
          'Unable to start download.',
        );
      }
    } catch (_) {
      _showMessage(
        'Unable to start download.',
      );
    }
  }

  // ============================================================
  // BACK HANDLING
  // ============================================================

  Future<void> _handleBackPressed() async {
    final controller =
        _webViewController;

    if (controller != null) {
      try {
        final canGoBack =
        await controller.canGoBack();

        if (canGoBack) {
          await controller.goBack();
          return;
        }
      } catch (_) {}
    }

    await _showExitDialog();
  }

  Future<void> _showExitDialog() async {
    if (_exitDialogShowing ||
        !mounted) {
      return;
    }

    _exitDialogShowing = true;

    final shouldExit =
    await showDialog<bool>(
      context: context,
      barrierDismissible: true,
      builder: (
          dialogContext,
          ) {
        return AlertDialog(
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.white,

          shape:
          RoundedRectangleBorder(
            borderRadius:
            BorderRadius.circular(22),
          ),

          title: Text(
            'Exit RiderSIM?',
            style:
            GoogleFonts.inter(
              color: _dark,
              fontSize: 20,
              fontWeight:
              FontWeight.w800,
            ),
          ),

          content: Text(
            'Are you sure you want to close the app?',
            style:
            GoogleFonts.inter(
              color: _gray,
              fontSize: 15,
              height: 1.4,
            ),
          ),

          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(
                  dialogContext,
                ).pop(false);
              },
              child: Text(
                'Cancel',
                style:
                GoogleFonts.inter(
                  color: _gray,
                  fontWeight:
                  FontWeight.w600,
                ),
              ),
            ),

            FilledButton(
              style:
              FilledButton.styleFrom(
                backgroundColor:
                _brandRed,
                foregroundColor:
                Colors.white,
              ),
              onPressed: () {
                Navigator.of(
                  dialogContext,
                ).pop(true);
              },
              child: Text(
                'Exit',
                style:
                GoogleFonts.inter(
                  fontWeight:
                  FontWeight.w700,
                ),
              ),
            ),
          ],
        );
      },
    );

    _exitDialogShowing = false;

    if (shouldExit != true) {
      return;
    }

    if (defaultTargetPlatform ==
        TargetPlatform.android) {
      await SystemNavigator.pop();
    }
  }

  // ============================================================
  // APP LIFECYCLE
  // ============================================================

  @override
  void didChangeAppLifecycleState(
      AppLifecycleState state,
      ) {
    if (state ==
        AppLifecycleState.resumed) {
      _checkConnectionAfterResume();
    }
  }

  Future<void>
  _checkConnectionAfterResume() async {
    try {
      final connected =
      await _internetConnection.hasInternetAccess;

      if (!mounted) return;

      if (!connected) {
        setState(() {
          _isOffline = true;
        });

        return;
      }

      if (_isOffline) {
        setState(() {
          _isOffline = false;
        });

        await _webViewController?.reload();
      }
    } catch (_) {}
  }

  // ============================================================
  // HOME
  // ============================================================

  Future<void> _goHome() async {
    if (_isOffline) return;

    setState(() {
      _hasPageError = false;
      _errorTitle = null;
      _errorDescription = null;
      _isLoading = true;
    });

    await _webViewController?.loadUrl(
      urlRequest: URLRequest(
        url: WebUri(_homeUrl),
      ),
    );
  }

  // ============================================================
  // MESSAGE
  // ============================================================

  void _showMessage(
      String message,
      ) {
    if (!mounted) return;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(
            message,
            style:
            GoogleFonts.inter(),
          ),
          behavior:
          SnackBarBehavior.floating,
          duration:
          const Duration(
            seconds: 2,
          ),
        ),
      );
  }

  // ============================================================
  // DISPOSE
  // ============================================================

  @override
  void dispose() {
    WidgetsBinding.instance
        .removeObserver(this);

    _pageTimeoutTimer?.cancel();

    _internetSubscription?.cancel();

    _internetConnection.dispose();

    super.dispose();
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(
      BuildContext context,
      ) {
    return PopScope(
      canPop: false,

      onPopInvokedWithResult: (
          didPop,
          result,
          ) {
        if (!didPop) {
          _handleBackPressed();
        }
      },

      child: Scaffold(
        backgroundColor:
        Colors.white,

        resizeToAvoidBottomInset:
        true,

        body: SafeArea(
          bottom: false,

          child: Stack(
            children: [
              Positioned.fill(
                child:
                _buildWebView(),
              ),

              // Keep native loader until actual page
              // becomes visible.
              if (!_initialPageVisible &&
                  !_isOffline &&
                  !_hasPageError)
                const Positioned.fill(
                  child:
                  _NativeLoadingView(),
                ),

              if (_isOffline)
                Positioned.fill(
                  child:
                  _OfflineView(
                    retrying:
                    _isRetrying,
                    onRetry:
                    _retry,
                  ),
                ),

              if (!_isOffline &&
                  _hasPageError)
                Positioned.fill(
                  child:
                  _ErrorView(
                    title:
                    _errorTitle ??
                        'Something went wrong',
                    description:
                    _errorDescription ??
                        'We couldn’t load this page. Please try again.',
                    retrying:
                    _isRetrying,
                    onRetry:
                    _retry,
                    onHome:
                    _goHome,
                  ),
                ),

              if (_initialPageVisible &&
                  !_isOffline &&
                  !_hasPageError &&
                  _isLoading)
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child:
                  _WebProgressBar(
                    progress:
                    _progress,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================
  // WEBVIEW
  // ============================================================

  Widget _buildWebView() {
    return InAppWebView(
      initialUrlRequest:
      URLRequest(
        url:
        WebUri(
          _homeUrl,
        ),
      ),

      initialSettings:
      _webSettings,

      pullToRefreshController:
      _pullToRefreshController,

      onWebViewCreated: (
          controller,
          ) {
        _webViewController =
            controller;
      },

      onLoadStart: (
          controller,
          url,
          ) {
        _currentUrl = url;

        _startPageTimeout();

        if (!mounted) return;

        setState(() {
          _isLoading = true;
          _progress = 0;

          _hasPageError = false;

          _errorTitle = null;
          _errorDescription = null;
        });
      },

      // IMPORTANT:
      // Hide native loader when WebView reports visible content.
      onPageCommitVisible: (
          controller,
          url,
          ) {
        _currentUrl = url;

        if (!mounted) return;

        if (!_initialPageVisible) {
          setState(() {
            _initialPageVisible = true;
          });
        }
      },

      onProgressChanged: (
          controller,
          progress,
          ) async {
        if (!mounted) return;

        setState(() {
          _progress = progress;
          _isLoading =
              progress < 100;

          /*
           * Fallback in case onPageCommitVisible
           * is delayed or unavailable on some device.
           */
          if (!_initialPageVisible &&
              progress >= 15) {
            _initialPageVisible = true;
          }
        });

        if (progress >= 100) {
          _stopPageTimeout();

          await _pullToRefreshController
              .endRefreshing();
        }
      },

      onLoadStop: (
          controller,
          url,
          ) async {
        _stopPageTimeout();

        _currentUrl = url;

        await _pullToRefreshController
            .endRefreshing();

        if (!mounted) return;

        setState(() {
          _initialPageVisible = true;

          _isLoading = false;

          _progress = 100;

          _hasPageError = false;
        });
      },

      shouldOverrideUrlLoading: (
          controller,
          navigationAction,
          ) {
        return _handleNavigation(
          navigationAction,
        );
      },

      onCreateWindow: (
          controller,
          action,
          ) {
        return _handleCreateWindow(
          controller,
          action,
        );
      },

      onDownloadStartRequest: (
          controller,
          request,
          ) {
        _handleDownload(
          request,
        );
      },

      onReceivedError: (
          controller,
          request,
          error,
          ) async {
        if (request.isForMainFrame != true) {
          return;
        }

        _stopPageTimeout();

        await _pullToRefreshController
            .endRefreshing();

        bool connected = true;

        try {
          connected =
          await _internetConnection
              .hasInternetAccess;
        } catch (_) {}

        if (!mounted) return;

        if (!connected) {
          setState(() {
            _isOffline = true;
            _isLoading = false;
          });

          return;
        }

        setState(() {
          _hasPageError = true;
          _isLoading = false;

          _errorTitle =
          'Unable to load page';

          _errorDescription =
          error.description.isNotEmpty
              ? error.description
              : 'Please try again.';
        });
      },

      onReceivedHttpError: (
          controller,
          request,
          response,
          ) async {
        if (request.isForMainFrame != true) {
          return;
        }

        final statusCode =
            response.statusCode ?? 0;

        if (statusCode < 400) {
          return;
        }

        _stopPageTimeout();

        await _pullToRefreshController
            .endRefreshing();

        if (!mounted) return;

        setState(() {
          _isLoading = false;

          _hasPageError = true;

          _errorTitle =
          'Page unavailable';

          _errorDescription =
          'The server returned error $statusCode. '
              'Please try again.';
        });
      },

      onWebContentProcessDidTerminate: (
          controller,
          ) async {
        await controller.reload();
      },
    );
  }
}

// ================================================================
// LOADING VIEW
// ================================================================

class _NativeLoadingView
    extends StatelessWidget {
  const _NativeLoadingView();

  @override
  Widget build(
      BuildContext context,
      ) {
    final width =
        MediaQuery.sizeOf(
          context,
        ).width;

    return ColoredBox(
      color:
      Colors.white,

      child: Center(
        child: Column(
          mainAxisSize:
          MainAxisSize.min,

          children: [
            RepaintBoundary(
              child:
              Image.asset(
                'assets/images/ridersim_logo.png',

                width:
                (width * 0.40)
                    .clamp(
                  135.0,
                  175.0,
                ),

                fit:
                BoxFit.contain,

                filterQuality:
                FilterQuality.low,
              ),
            ),

            const SizedBox(
              height:
              24,
            ),

            const SizedBox(
              width:
              27,
              height:
              27,

              child:
              CircularProgressIndicator(
                strokeWidth:
                2.4,

                color:
                Color(
                  0xFFEE0018,
                ),
              ),
            ),

            const SizedBox(
              height:
              14,
            ),

            Text(
              'Connecting you...',

              style:
              GoogleFonts.inter(
                color:
                const Color(
                  0xFF69707A,
                ),

                fontSize:
                14,

                fontWeight:
                FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ================================================================
// PROGRESS BAR
// ================================================================

class _WebProgressBar
    extends StatelessWidget {
  const _WebProgressBar({
    required this.progress,
  });

  final int progress;

  @override
  Widget build(
      BuildContext context,
      ) {
    return IgnorePointer(
      child:
      LinearProgressIndicator(
        value:
        progress <= 0
            ? null
            : progress / 100,

        minHeight:
        2,

        backgroundColor:
        const Color(
          0x12EE0018,
        ),

        valueColor:
        const AlwaysStoppedAnimation<Color>(
          Color(
            0xFFEE0018,
          ),
        ),
      ),
    );
  }
}

// ================================================================
// OFFLINE VIEW
// ================================================================

class _OfflineView
    extends StatelessWidget {
  const _OfflineView({
    required this.retrying,
    required this.onRetry,
  });

  final bool retrying;
  final VoidCallback onRetry;

  @override
  Widget build(
      BuildContext context,
      ) {
    final width =
        MediaQuery.sizeOf(
          context,
        ).width;

    return ColoredBox(
      color:
      Colors.white,

      child: Center(
        child:
        SingleChildScrollView(
          padding:
          EdgeInsets.symmetric(
            horizontal:
            width * 0.11,

            vertical:
            30,
          ),

          child: Column(
            mainAxisSize:
            MainAxisSize.min,

            children: [
              Container(
                width:
                88,
                height:
                88,

                decoration:
                const BoxDecoration(
                  color:
                  Color(
                    0xFFFFECEE,
                  ),
                  shape:
                  BoxShape.circle,
                ),

                child:
                const Icon(
                  Icons
                      .wifi_off_rounded,

                  color:
                  Color(
                    0xFFEE0018,
                  ),

                  size:
                  41,
                ),
              ),

              const SizedBox(
                height:
                25,
              ),

              Text(
                'No Internet Connection',

                textAlign:
                TextAlign.center,

                style:
                GoogleFonts.inter(
                  color:
                  const Color(
                    0xFF080808,
                  ),

                  fontSize:
                  22,

                  fontWeight:
                  FontWeight.w800,

                  letterSpacing:
                  -0.5,
                ),
              ),

              const SizedBox(
                height:
                11,
              ),

              Text(
                'Check your Wi-Fi or mobile data connection and try again.',

                textAlign:
                TextAlign.center,

                style:
                GoogleFonts.inter(
                  color:
                  const Color(
                    0xFF68707B,
                  ),

                  fontSize:
                  15,

                  height:
                  1.45,
                ),
              ),

              const SizedBox(
                height:
                28,
              ),

              _RetryButton(
                loading:
                retrying,
                text:
                'Try Again',
                onPressed:
                onRetry,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ================================================================
// ERROR VIEW
// ================================================================

class _ErrorView
    extends StatelessWidget {
  const _ErrorView({
    required this.title,
    required this.description,
    required this.retrying,
    required this.onRetry,
    required this.onHome,
  });

  final String title;
  final String description;
  final bool retrying;

  final VoidCallback onRetry;
  final VoidCallback onHome;

  @override
  Widget build(
      BuildContext context,
      ) {
    final width =
        MediaQuery.sizeOf(
          context,
        ).width;

    return ColoredBox(
      color:
      Colors.white,

      child: Center(
        child:
        SingleChildScrollView(
          padding:
          EdgeInsets.symmetric(
            horizontal:
            width * 0.10,

            vertical:
            30,
          ),

          child: Column(
            mainAxisSize:
            MainAxisSize.min,

            children: [
              Container(
                width:
                88,
                height:
                88,

                decoration:
                const BoxDecoration(
                  color:
                  Color(
                    0xFFFFECEE,
                  ),
                  shape:
                  BoxShape.circle,
                ),

                child:
                const Icon(
                  Icons
                      .error_outline_rounded,

                  color:
                  Color(
                    0xFFEE0018,
                  ),

                  size:
                  42,
                ),
              ),

              const SizedBox(
                height:
                24,
              ),

              Text(
                title,

                textAlign:
                TextAlign.center,

                style:
                GoogleFonts.inter(
                  color:
                  const Color(
                    0xFF080808,
                  ),

                  fontSize:
                  22,

                  fontWeight:
                  FontWeight.w800,

                  letterSpacing:
                  -0.5,
                ),
              ),

              const SizedBox(
                height:
                11,
              ),

              Text(
                description,

                textAlign:
                TextAlign.center,

                style:
                GoogleFonts.inter(
                  color:
                  const Color(
                    0xFF68707B,
                  ),

                  fontSize:
                  15,

                  height:
                  1.45,
                ),
              ),

              const SizedBox(
                height:
                28,
              ),

              _RetryButton(
                loading:
                retrying,
                text:
                'Try Again',
                onPressed:
                onRetry,
              ),

              const SizedBox(
                height:
                10,
              ),

              TextButton(
                onPressed:
                onHome,

                child:
                Text(
                  'Back to Home',

                  style:
                  GoogleFonts.inter(
                    color:
                    const Color(
                      0xFF68707B,
                    ),

                    fontWeight:
                    FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ================================================================
// RETRY BUTTON
// ================================================================

class _RetryButton
    extends StatelessWidget {
  const _RetryButton({
    required this.loading,
    required this.text,
    required this.onPressed,
  });

  final bool loading;
  final String text;
  final VoidCallback onPressed;

  @override
  Widget build(
      BuildContext context,
      ) {
    return SizedBox(
      width:
      double.infinity,

      height:
      55,

      child:
      FilledButton(
        onPressed:
        loading
            ? null
            : onPressed,

        style:
        FilledButton.styleFrom(
          backgroundColor:
          const Color(
            0xFFEE0018,
          ),

          disabledBackgroundColor:
          const Color(
            0xFFEE0018,
          ).withOpacity(
            0.65,
          ),

          foregroundColor:
          Colors.white,

          elevation:
          0,

          shape:
          RoundedRectangleBorder(
            borderRadius:
            BorderRadius.circular(
              100,
            ),
          ),
        ),

        child:
        AnimatedSwitcher(
          duration:
          const Duration(
            milliseconds:
            160,
          ),

          child:
          loading
              ? const SizedBox(
            key:
            ValueKey(
              'loader',
            ),

            width:
            21,

            height:
            21,

            child:
            CircularProgressIndicator(
              strokeWidth:
              2.3,

              color:
              Colors.white,
            ),
          )
              : Text(
            text,

            key:
            const ValueKey(
              'text',
            ),

            style:
            GoogleFonts.inter(
              fontSize:
              16,

              fontWeight:
              FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }
}