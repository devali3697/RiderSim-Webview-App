import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:google_fonts/google_fonts.dart';

import '../services/connectivity_service.dart';
import '../services/url_handler_service.dart';

import '../widgets/app_dialogs.dart';
import '../widgets/web_loading_bar.dart';

import 'error_screen.dart';
import 'offline_screen.dart';

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
  // ============================================================
  // CONSTANTS
  // ============================================================

  static const String _homeUrl =
      'https://www.ridersim.com/';

  static const Color _brandRed =
  Color(0xFFEE0018);

  // ============================================================
  // WEBVIEW
  // ============================================================

  InAppWebViewController? _webViewController;

  late final PullToRefreshController
  _pullToRefreshController;

  // ============================================================
  // CONNECTIVITY
  // ============================================================

  StreamSubscription<bool>?
  _internetSubscription;

  // ============================================================
  // TIMEOUT
  // ============================================================

  Timer? _pageTimeoutTimer;

  // ============================================================
  // STATE
  // ============================================================

  bool _isOffline = false;

  bool _initialPageVisible = false;

  bool _hasPageError = false;

  bool _isLoading = true;

  bool _isRetrying = false;

  bool _exitDialogShowing = false;

  int _progress = 0;

  String? _errorTitle;

  String? _errorDescription;

  // ============================================================
  // WEBVIEW SETTINGS
  // ============================================================

  final InAppWebViewSettings _webSettings =
  InAppWebViewSettings(
    // Navigation interception.
    useShouldOverrideUrlLoading: true,

    // Downloads.
    useOnDownloadStart: true,

    // JavaScript.
    javaScriptEnabled: true,

    javaScriptCanOpenWindowsAutomatically:
    true,

    // Needed for target="_blank" / window.open().
    supportMultipleWindows: true,

    // Important for checkout/session flow.
    thirdPartyCookiesEnabled: true,

    sharedCookiesEnabled: true,

    // Cache.
    cacheEnabled: true,

    // Responsive website behavior.
    useWideViewPort: true,

    loadWithOverviewMode: true,

    // Disable WebView zoom controls.
    supportZoom: false,

    builtInZoomControls: false,

    displayZoomControls: false,

    // Native-looking UI.
    verticalScrollBarEnabled: false,

    horizontalScrollBarEnabled: false,

    // Media.
    allowsInlineMediaPlayback: true,

    mediaPlaybackRequiresUserGesture:
    true,

    // Performance.
    hardwareAcceleration: true,

    // ==========================================================
    // IMPORTANT
    // ==========================================================
    //
    // Keep this FALSE.
    //
    // Hybrid Composition caused SurfaceView /
    // BLASTBufferQueue problems on the tested TECNO device.
    //
    // This configuration is already confirmed working.
    // ==========================================================

    useHybridComposition: false,

    // We show our own native error screen.
    disableDefaultErrorPage: true,

    // Security.
    allowFileAccessFromFileURLs: false,

    allowUniversalAccessFromFileURLs:
    false,

    // Mobile website.
    preferredContentMode:
    UserPreferredContentMode.MOBILE,

    // Background.
    transparentBackground: false,

    underPageBackgroundColor:
    Colors.white,
  );

  // ============================================================
  // INIT
  // ============================================================

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance
        .addObserver(this);

    _setupSystemUi();

    // ==========================================================
    // PULL TO REFRESH
    // ==========================================================

    _pullToRefreshController =
        PullToRefreshController(
          settings:
          PullToRefreshSettings(
            color: _brandRed,
            backgroundColor:
            Colors.white,
          ),

          onRefresh:
          _refreshWebView,
        );

    // ==========================================================
    // CONNECTIVITY
    // ==========================================================
    //
    // Important:
    //
    // Connectivity check happens in background.
    // WebView is NOT blocked while waiting for it.
    // ==========================================================

    _initialiseConnectivity();
  }

  // ============================================================
  // SYSTEM UI
  // ============================================================

  void _setupSystemUi() {
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.edgeToEdge,
    );

    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor:
        Colors.white,

        statusBarIconBrightness:
        Brightness.dark,

        statusBarBrightness:
        Brightness.light,

        systemNavigationBarColor:
        Colors.white,

        systemNavigationBarIconBrightness:
        Brightness.dark,

        systemNavigationBarDividerColor:
        Colors.transparent,

        systemNavigationBarContrastEnforced:
        false,
      ),
    );
  }

  // ============================================================
  // CONNECTIVITY
  // ============================================================

  Future<void>
  _initialiseConnectivity() async {
    // Listen for future internet changes.

    _internetSubscription =
        ConnectivityService
            .connectionStream
            .listen(
          _handleInternetStatus,
        );

    // Initial check in background.

    try {
      final hasInternet =
      await ConnectivityService
          .hasInternet();

      if (!mounted) {
        return;
      }

      if (!hasInternet) {
        setState(() {
          _isOffline = true;
        });
      }
    } catch (_) {
      // Do nothing here.
      //
      // WebView callbacks will handle
      // any actual loading failure.
    }
  }

  void _handleInternetStatus(
      bool connected,
      ) {
    if (!mounted) {
      return;
    }

    final bool wasOffline =
        _isOffline;

    // No state change.
    if (connected &&
        !_isOffline) {
      return;
    }

    // No state change.
    if (!connected &&
        _isOffline) {
      return;
    }

    setState(() {
      _isOffline =
      !connected;
    });

    // Internet returned.
    if (connected &&
        wasOffline) {
      _recoverAfterConnection();
    }
  }

  Future<void>
  _recoverAfterConnection() async {
    if (!mounted) {
      return;
    }

    setState(() {
      _hasPageError = false;

      _errorTitle = null;

      _errorDescription = null;

      _isLoading = true;
    });

    // Give network a tiny moment to settle.
    await Future<void>.delayed(
      const Duration(
        milliseconds: 150,
      ),
    );

    if (!mounted) {
      return;
    }

    try {
      await _webViewController
          ?.reload();
    } catch (_) {
      // Loading callbacks will handle it.
    }
  }

  // ============================================================
  // PULL TO REFRESH
  // ============================================================

  Future<void>
  _refreshWebView() async {
    try {
      final connected =
      await ConnectivityService
          .hasInternet();

      if (!mounted) {
        return;
      }

      // No internet.
      if (!connected) {
        setState(() {
          _isOffline = true;
        });

        await _pullToRefreshController
            .endRefreshing();

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
        await _pullToRefreshController
            .endRefreshing();
      }
    } catch (_) {
      await _pullToRefreshController
          .endRefreshing();
    }
  }

  // ============================================================
  // RETRY
  // ============================================================

  Future<void> _retry() async {
    // Prevent double taps.
    if (_isRetrying) {
      return;
    }

    if (!mounted) {
      return;
    }

    setState(() {
      _isRetrying = true;
    });

    try {
      final connected =
      await ConnectivityService
          .hasInternet();

      if (!mounted) {
        return;
      }

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

      final controller =
          _webViewController;

      if (controller != null) {
        await controller.reload();
      } else {
        await _goHome();
      }
    } catch (_) {
      if (!mounted) {
        return;
      }

      setState(() {
        _isRetrying = false;
      });
    }
  }

  // ============================================================
  // PAGE TIMEOUT
  // ============================================================

  void _startPageTimeout() {
    _pageTimeoutTimer
        ?.cancel();

    _pageTimeoutTimer =
        Timer(
          const Duration(
            seconds: 15,
          ),
              () {
            if (!mounted) {
              return;
            }

            // Only use the timeout while the
            // initial WebView page has not become visible.
            //
            // We don't want to throw timeout screens
            // during normal internal navigation.

            if (_isLoading &&
                !_isOffline &&
                !_initialPageVisible) {
              setState(() {
                _hasPageError =
                true;

                _isLoading =
                false;

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
    _pageTimeoutTimer
        ?.cancel();

    _pageTimeoutTimer =
    null;
  }

  // ============================================================
  // URL NAVIGATION
  // ============================================================

  Future<NavigationActionPolicy>
  _handleNavigation(
      NavigationAction navigationAction,
      ) {
    return UrlHandlerService
        .handleNavigation(
      navigationAction,

      onLaunchFailed: (
          message,
          ) {
        _showMessage(
          message,
        );
      },
    );
  }

  // ============================================================
  // TARGET="_BLANK" / WINDOW.OPEN()
  // ============================================================

  Future<bool?>
  _handleCreateWindow(
      InAppWebViewController controller,
      CreateWindowAction action,
      ) {
    return UrlHandlerService
        .handleCreateWindow(
      controller,
      action,

      onLaunchFailed: (
          message,
          ) {
        _showMessage(
          message,
        );
      },
    );
  }

  // ============================================================
  // DOWNLOAD
  // ============================================================

  Future<void> _handleDownload(
      DownloadStartRequest request,
      ) async {
    try {
      final uri =
      Uri.parse(
        request.url.toString(),
      );

      final opened =
      await UrlHandlerService
          .openDownload(
        uri,
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
  // BACK BUTTON
  // ============================================================

  Future<void>
  _handleBackPressed() async {
    final controller =
        _webViewController;

    if (controller != null) {
      try {
        final canGoBack =
        await controller
            .canGoBack();

        if (canGoBack) {
          await controller
              .goBack();

          return;
        }
      } catch (_) {
        // Continue to exit dialog.
      }
    }

    await _showExitDialog();
  }

  // ============================================================
  // EXIT DIALOG
  // ============================================================

  Future<void>
  _showExitDialog() async {
    if (_exitDialogShowing ||
        !mounted) {
      return;
    }

    _exitDialogShowing =
    true;

    final shouldExit =
    await AppDialogs
        .showExitDialog(
      context,
    );

    _exitDialogShowing =
    false;

    if (!mounted) {
      return;
    }

    if (!shouldExit) {
      return;
    }

    // Android apps can explicitly close.
    //
    // iOS apps should NOT programmatically
    // terminate themselves.

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
      await ConnectivityService
          .hasInternet();

      if (!mounted) {
        return;
      }

      // App resumed without internet.
      if (!connected) {
        setState(() {
          _isOffline = true;
        });

        return;
      }

      // Internet returned while app
      // was backgrounded.
      if (_isOffline) {
        setState(() {
          _isOffline = false;

          _hasPageError =
          false;

          _errorTitle =
          null;

          _errorDescription =
          null;
        });

        await _webViewController
            ?.reload();
      }
    } catch (_) {
      // Ignore.
    }
  }

  // ============================================================
  // HOME
  // ============================================================

  Future<void> _goHome() async {
    final connected =
    await ConnectivityService
        .hasInternet();

    if (!mounted) {
      return;
    }

    if (!connected) {
      setState(() {
        _isOffline = true;
      });

      return;
    }

    setState(() {
      _isOffline = false;

      _hasPageError = false;

      _errorTitle = null;

      _errorDescription = null;

      _isLoading = true;
    });

    try {
      await _webViewController
          ?.loadUrl(
        urlRequest:
        URLRequest(
          url: WebUri(
            _homeUrl,
          ),
        ),
      );
    } catch (_) {
      _showMessage(
        'Unable to open RiderSIM home page.',
      );
    }
  }

  // ============================================================
  // MESSAGE
  // ============================================================

  void _showMessage(
      String message,
      ) {
    if (!mounted) {
      return;
    }

    ScaffoldMessenger
        .of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(
            message,
            style:
            GoogleFonts.inter(),
          ),

          behavior:
          SnackBarBehavior
              .floating,

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

    _stopPageTimeout();

    _internetSubscription
        ?.cancel();

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
      // We handle Android back manually
      // because WebView has its own history.
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
              // ================================================
              // WEBVIEW
              // ================================================
              //
              // IMPORTANT:
              //
              // WebView is ALWAYS mounted immediately.
              //
              // We do not wait for connectivity checks.
              // ================================================

              Positioned.fill(
                child:
                _buildWebView(),
              ),

              // ================================================
              // INITIAL NATIVE LOADER
              // ================================================
              //
              // Stays visible until WebView content is actually
              // committed/visible.
              // ================================================

              if (!_initialPageVisible &&
                  !_isOffline &&
                  !_hasPageError)
                const Positioned.fill(
                  child:
                  _NativeLoadingView(),
                ),

              // ================================================
              // OFFLINE
              // ================================================

              if (_isOffline)
                Positioned.fill(
                  child:
                  OfflineScreen(
                    isRetrying:
                    _isRetrying,

                    onRetry:
                    _retry,
                  ),
                ),

              // ================================================
              // ERROR
              // ================================================

              if (!_isOffline &&
                  _hasPageError)
                Positioned.fill(
                  child:
                  ErrorScreen(
                    title:
                    _errorTitle ??
                        'Something went wrong',

                    description:
                    _errorDescription ??
                        'We couldn’t load this page. Please try again.',

                    isRetrying:
                    _isRetrying,

                    onRetry:
                    _retry,

                    onHome:
                    _goHome,
                  ),
                ),

              // ================================================
              // WEB PROGRESS BAR
              // ================================================

              if (_initialPageVisible &&
                  !_isOffline &&
                  !_hasPageError &&
                  _isLoading)
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,

                  child:
                  WebLoadingBar(
                    progress:
                    _progress /
                        100.0,

                    visible:
                    _progress <
                        100,
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
      // ========================================================
      // INITIAL URL
      // ========================================================

      initialUrlRequest:
      URLRequest(
        url: WebUri(
          _homeUrl,
        ),
      ),

      // ========================================================
      // SETTINGS
      // ========================================================

      initialSettings:
      _webSettings,

      // ========================================================
      // PULL TO REFRESH
      // ========================================================

      pullToRefreshController:
      _pullToRefreshController,

      // ========================================================
      // WEBVIEW CREATED
      // ========================================================

      onWebViewCreated: (
          controller,
          ) {
        _webViewController =
            controller;
      },

      // ========================================================
      // LOAD START
      // ========================================================

      onLoadStart: (
          controller,
          url,
          ) {
        _startPageTimeout();

        if (!mounted) {
          return;
        }

        setState(() {
          _isLoading = true;

          _progress = 0;

          _hasPageError =
          false;

          _errorTitle =
          null;

          _errorDescription =
          null;
        });
      },

      // ========================================================
      // PAGE CONTENT ACTUALLY VISIBLE
      // ========================================================
      //
      // This callback is important.
      //
      // We don't hide the initial native loader based on a
      // hard-coded timer.
      //
      // It hides when WebView reports visible content.
      // ========================================================

      onPageCommitVisible: (
          controller,
          url,
          ) {
        if (!mounted) {
          return;
        }

        if (!_initialPageVisible) {
          setState(() {
            _initialPageVisible =
            true;
          });
        }
      },

      // ========================================================
      // PROGRESS
      // ========================================================

      onProgressChanged: (
          controller,
          progress,
          ) async {
        if (!mounted) {
          return;
        }

        setState(() {
          _progress =
              progress;

          _isLoading =
              progress < 100;

          // Fallback for devices where
          // onPageCommitVisible can be delayed.
          //
          // This behavior is intentionally preserved from the
          // working implementation.

          if (!_initialPageVisible &&
              progress >= 15) {
            _initialPageVisible =
            true;
          }
        });

        if (progress >= 100) {
          _stopPageTimeout();

          await _pullToRefreshController
              .endRefreshing();
        }
      },

      // ========================================================
      // LOAD COMPLETE
      // ========================================================

      onLoadStop: (
          controller,
          url,
          ) async {
        _stopPageTimeout();

        await _pullToRefreshController
            .endRefreshing();

        if (!mounted) {
          return;
        }

        setState(() {
          _initialPageVisible =
          true;

          _isLoading =
          false;

          _progress =
          100;

          _hasPageError =
          false;

          _errorTitle =
          null;

          _errorDescription =
          null;
        });
      },

      // ========================================================
      // NAVIGATION
      // ========================================================

      shouldOverrideUrlLoading: (
          controller,
          navigationAction,
          ) {
        return _handleNavigation(
          navigationAction,
        );
      },

      // ========================================================
      // TARGET="_BLANK" / WINDOW.OPEN()
      // ========================================================

      onCreateWindow: (
          controller,
          action,
          ) {
        return _handleCreateWindow(
          controller,
          action,
        );
      },

      // ========================================================
      // DOWNLOAD
      // ========================================================

      onDownloadStartRequest: (
          controller,
          request,
          ) {
        _handleDownload(
          request,
        );
      },

      // ========================================================
      // NORMAL WEB ERROR
      // ========================================================

      onReceivedError: (
          controller,
          request,
          error,
          ) async {
        // Ignore image/CSS/script errors.
        //
        // Only show native error UI when the
        // MAIN document fails.

        if (request.isForMainFrame !=
            true) {
          return;
        }

        _stopPageTimeout();

        await _pullToRefreshController
            .endRefreshing();

        final connected =
        await ConnectivityService
            .hasInternet();

        if (!mounted) {
          return;
        }

        // Internet disappeared.
        if (!connected) {
          setState(() {
            _isOffline =
            true;

            _isLoading =
            false;
          });

          return;
        }

        setState(() {
          _isOffline =
          false;

          _hasPageError =
          true;

          _isLoading =
          false;

          _errorTitle =
          'Unable to load page';

          _errorDescription =
          error.description
              .isNotEmpty
              ? error.description
              : 'Please try again.';
        });
      },

      // ========================================================
      // HTTP ERROR
      // ========================================================

      onReceivedHttpError: (
          controller,
          request,
          response,
          ) async {
        // Ignore sub-resource HTTP errors.
        if (request.isForMainFrame !=
            true) {
          return;
        }

        final int statusCode =
            response.statusCode ??
                0;

        if (statusCode < 400) {
          return;
        }

        _stopPageTimeout();

        await _pullToRefreshController
            .endRefreshing();

        if (!mounted) {
          return;
        }

        setState(() {
          _isLoading =
          false;

          _hasPageError =
          true;

          _errorTitle =
          'Page unavailable';

          _errorDescription =
          'The server returned error $statusCode. '
              'Please try again.';
        });
      },

      // ========================================================
      // WEB CONTENT PROCESS TERMINATED
      // ========================================================
      //
      // Mostly relevant to iOS / WebKit process termination.
      // Reload instead of showing a dead WebView.
      // ========================================================

      onWebContentProcessDidTerminate: (
          controller,
          ) async {
        try {
          await controller.reload();
        } catch (_) {
          if (!mounted) {
            return;
          }

          setState(() {
            _hasPageError =
            true;

            _isLoading =
            false;

            _errorTitle =
            'Unable to restore page';

            _errorDescription =
            'Please try again.';
          });
        }
      },
    );
  }
}

// ================================================================
// INITIAL NATIVE LOADING VIEW
// ================================================================
//
// This remains here intentionally.
//
// It belongs specifically to WebView startup,
// unlike offline/error UI which are reusable screens.
// ================================================================

class _NativeLoadingView extends StatelessWidget {
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
            // RiderSIM logo.

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
              height: 24,
            ),

            const SizedBox(
              width: 27,
              height: 27,

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
              height: 14,
            ),

            Text(
              'Connecting you...',

              style:
              GoogleFonts.inter(
                color:
                const Color(
                  0xFF69707A,
                ),

                fontSize: 14,

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