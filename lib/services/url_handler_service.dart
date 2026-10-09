import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:url_launcher/url_launcher.dart';

class UrlHandlerService {
  UrlHandlerService._();

  // ============================================================
  // INTERNAL HOSTS
  // ============================================================

  static bool isRiderSimHost(
      String host,
      ) {
    final normalized =
    host.toLowerCase();

    return normalized == 'ridersim.com' ||
        normalized == 'www.ridersim.com' ||
        normalized.endsWith(
          '.ridersim.com',
        );
  }

  static bool isBreezeHost(
      String host,
      ) {
    final normalized =
    host.toLowerCase();

    return normalized == 'breezesim.com' ||
        normalized == 'www.breezesim.com' ||
        normalized.endsWith(
          '.breezesim.com',
        );
  }

  // ============================================================
  // EXTERNAL HOSTS
  // ============================================================

  static const Set<String> _externalHosts = {
    // WhatsApp
    'wa.me',
    'api.whatsapp.com',
    'web.whatsapp.com',

    // Instagram
    'instagram.com',
    'www.instagram.com',

    // Facebook
    'facebook.com',
    'www.facebook.com',
    'm.facebook.com',

    // YouTube
    'youtube.com',
    'www.youtube.com',
    'youtu.be',

    // TikTok
    'tiktok.com',
    'www.tiktok.com',

    // LinkedIn
    'linkedin.com',
    'www.linkedin.com',

    // Twitter / X
    'twitter.com',
    'www.twitter.com',
    'x.com',
    'www.x.com',

    // Maps
    'maps.google.com',
  };

  // ============================================================
  // EXTERNAL SCHEMES
  // ============================================================

  static const Set<String> _externalSchemes = {
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

  // ============================================================
  // SAFE INTERNAL WEBVIEW SCHEMES
  // ============================================================

  static const Set<String> _internalWebViewSchemes = {
    'about',
    'javascript',
    'data',
    'blob',
  };

  // ============================================================
  // SHOULD OPEN HTTP URL EXTERNALLY
  // ============================================================

  static bool shouldOpenHttpUrlExternally(
      Uri uri,
      ) {
    final host =
    uri.host.toLowerCase();

    // RiderSIM stays inside the app.
    if (isRiderSimHost(host)) {
      return false;
    }

    // Breeze checkout stays inside the app.
    if (isBreezeHost(host)) {
      return false;
    }

    return _externalHosts.contains(
      host,
    );
  }

  // ============================================================
  // URL TYPE HELPERS
  // ============================================================

  static bool isHttpOrHttps(
      Uri uri,
      ) {
    final scheme =
    uri.scheme.toLowerCase();

    return scheme == 'http' ||
        scheme == 'https';
  }

  static bool isExternalScheme(
      Uri uri,
      ) {
    return _externalSchemes.contains(
      uri.scheme.toLowerCase(),
    );
  }

  static bool isInternalWebViewScheme(
      Uri uri,
      ) {
    return _internalWebViewSchemes.contains(
      uri.scheme.toLowerCase(),
    );
  }

  // ============================================================
  // EXTERNAL LAUNCH
  // ============================================================

  static Future<bool> launchExternal(
      Uri uri,
      ) async {
    try {
      return await launchUrl(
        uri,
        mode:
        LaunchMode.externalApplication,
      );
    } catch (_) {
      return false;
    }
  }

  // ============================================================
  // HANDLE NORMAL NAVIGATION
  // ============================================================

  static Future<NavigationActionPolicy>
  handleNavigation(
      NavigationAction navigationAction, {
        void Function(String message)?
        onLaunchFailed,
      }) async {
    final WebUri? webUri =
        navigationAction.request.url;

    if (webUri == null) {
      return NavigationActionPolicy.ALLOW;
    }

    final Uri uri =
    Uri.parse(
      webUri.toString(),
    );

    // ----------------------------------------------------------
    // HTTP / HTTPS
    // ----------------------------------------------------------

    if (isHttpOrHttps(uri)) {
      if (shouldOpenHttpUrlExternally(
        uri,
      )) {
        final opened =
        await launchExternal(uri);

        if (!opened) {
          onLaunchFailed?.call(
            'Unable to open this link.',
          );
        }

        return NavigationActionPolicy.CANCEL;
      }

      return NavigationActionPolicy.ALLOW;
    }

    // ----------------------------------------------------------
    // EXTERNAL APP SCHEMES
    // ----------------------------------------------------------

    if (isExternalScheme(uri)) {
      final opened =
      await launchExternal(uri);

      if (!opened) {
        onLaunchFailed?.call(
          'Unable to open this link.',
        );
      }

      return NavigationActionPolicy.CANCEL;
    }

    // ----------------------------------------------------------
    // SAFE WEBVIEW SCHEMES
    // ----------------------------------------------------------

    if (isInternalWebViewScheme(uri)) {
      return NavigationActionPolicy.ALLOW;
    }

    // ----------------------------------------------------------
    // UNKNOWN CUSTOM SCHEMES
    // ----------------------------------------------------------

    if (uri.scheme.isNotEmpty) {
      final opened =
      await launchExternal(uri);

      if (!opened) {
        onLaunchFailed?.call(
          'Unable to open this link.',
        );
      }

      return NavigationActionPolicy.CANCEL;
    }

    return NavigationActionPolicy.ALLOW;
  }

  // ============================================================
  // HANDLE TARGET="_BLANK" / WINDOW.OPEN
  // ============================================================

  static Future<bool?> handleCreateWindow(
      InAppWebViewController controller,
      CreateWindowAction action, {
        void Function(String message)?
        onLaunchFailed,
      }) async {
    final WebUri? webUri =
        action.request.url;

    if (webUri == null) {
      return false;
    }

    final Uri uri =
    Uri.parse(
      webUri.toString(),
    );

    // ----------------------------------------------------------
    // WEB URL
    // ----------------------------------------------------------

    if (isHttpOrHttps(uri)) {
      if (shouldOpenHttpUrlExternally(
        uri,
      )) {
        final opened =
        await launchExternal(uri);

        if (!opened) {
          onLaunchFailed?.call(
            'Unable to open this link.',
          );
        }
      } else {
        // RiderSIM / Breeze -> same WebView.
        await controller.loadUrl(
          urlRequest:
          URLRequest(
            url: webUri,
          ),
        );
      }

      return true;
    }

    // ----------------------------------------------------------
    // CUSTOM / EXTERNAL SCHEME
    // ----------------------------------------------------------

    final opened =
    await launchExternal(uri);

    if (!opened) {
      onLaunchFailed?.call(
        'Unable to open this link.',
      );
    }

    return true;
  }

  // ============================================================
  // DOWNLOAD URL
  // ============================================================

  static Future<bool> openDownload(
      Uri uri,
      ) async {
    return launchExternal(uri);
  }
}