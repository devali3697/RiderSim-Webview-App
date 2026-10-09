import 'dart:io';

import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

enum AppUpdateType {
  none,
  optional,
  required,
}

class AppUpdateResult {
  const AppUpdateResult({
    required this.type,
    required this.currentVersion,
    required this.latestVersion,
    required this.minimumVersion,
  });

  final AppUpdateType type;

  final String currentVersion;
  final String latestVersion;
  final String minimumVersion;

  bool get hasUpdate {
    return type != AppUpdateType.none;
  }

  bool get isRequired {
    return type == AppUpdateType.required;
  }

  bool get isOptional {
    return type == AppUpdateType.optional;
  }
}

class AppUpdateService {
  AppUpdateService._();

  // ============================================================
  // STORE URLS
  // ============================================================

  /*
   * IMPORTANT:
   *
   * Android package name ko release package name se replace karna.
   *
   * Example:
   * com.ridersim.app
   *
   * iOS App Store ID jab mil jaye tab replace karna.
   */

  static const String _androidPackageName =
      'com.example.ridersim_webview_app';

  static const String _iosAppStoreId =
      '';

  // ============================================================
  // CURRENT APP VERSION
  // ============================================================

  static Future<String> getCurrentVersion() async {
    final info =
    await PackageInfo.fromPlatform();

    return info.version;
  }

  static Future<String> getBuildNumber() async {
    final info =
    await PackageInfo.fromPlatform();

    return info.buildNumber;
  }

  // ============================================================
  // CHECK UPDATE
  // ============================================================

  /*
   * For now latestVersion and minimumVersion
   * will come from wherever you decide later:
   *
   * Firebase Remote Config
   * Supabase
   * custom API
   * your own JSON endpoint
   *
   * Example:
   *
   * latestVersion = 1.2.0
   * minimumVersion = 1.1.0
   */

  static Future<AppUpdateResult> checkUpdate({
    required String latestVersion,
    required String minimumVersion,
  }) async {
    final currentVersion =
    await getCurrentVersion();

    final bool belowMinimum =
        compareVersions(
          currentVersion,
          minimumVersion,
        ) <
            0;

    if (belowMinimum) {
      return AppUpdateResult(
        type:
        AppUpdateType.required,
        currentVersion:
        currentVersion,
        latestVersion:
        latestVersion,
        minimumVersion:
        minimumVersion,
      );
    }

    final bool updateAvailable =
        compareVersions(
          currentVersion,
          latestVersion,
        ) <
            0;

    if (updateAvailable) {
      return AppUpdateResult(
        type:
        AppUpdateType.optional,
        currentVersion:
        currentVersion,
        latestVersion:
        latestVersion,
        minimumVersion:
        minimumVersion,
      );
    }

    return AppUpdateResult(
      type:
      AppUpdateType.none,
      currentVersion:
      currentVersion,
      latestVersion:
      latestVersion,
      minimumVersion:
      minimumVersion,
    );
  }

  // ============================================================
  // VERSION COMPARISON
  // ============================================================

  /*
   * Returns:
   *
   * -1 => versionA < versionB
   *  0 => equal
   *  1 => versionA > versionB
   *
   * Examples:
   *
   * 1.0.0 vs 1.0.1 => -1
   * 1.2.0 vs 1.1.9 => 1
   * 2.0 vs 2.0.0 => 0
   */

  static int compareVersions(
      String versionA,
      String versionB,
      ) {
    final List<int> a =
    _normalizeVersion(
      versionA,
    );

    final List<int> b =
    _normalizeVersion(
      versionB,
    );

    final int maxLength =
    a.length > b.length
        ? a.length
        : b.length;

    for (
    int i = 0;
    i < maxLength;
    i++
    ) {
      final int valueA =
      i < a.length
          ? a[i]
          : 0;

      final int valueB =
      i < b.length
          ? b[i]
          : 0;

      if (valueA < valueB) {
        return -1;
      }

      if (valueA > valueB) {
        return 1;
      }
    }

    return 0;
  }

  static List<int> _normalizeVersion(
      String version,
      ) {
    /*
     * Removes things like:
     *
     * v1.2.3
     * 1.2.3+10
     * 1.2.3-beta
     *
     * For this app we compare numeric
     * semantic version only.
     */

    String cleaned =
    version.trim().toLowerCase();

    if (cleaned.startsWith('v')) {
      cleaned =
          cleaned.substring(1);
    }

    if (cleaned.contains('+')) {
      cleaned =
          cleaned.split('+').first;
    }

    if (cleaned.contains('-')) {
      cleaned =
          cleaned.split('-').first;
    }

    return cleaned
        .split('.')
        .map(
          (part) =>
      int.tryParse(part) ??
          0,
    )
        .toList();
  }

  // ============================================================
  // OPEN STORE
  // ============================================================

  static Future<bool> openStore() async {
    if (Platform.isAndroid) {
      return _openAndroidStore();
    }

    if (Platform.isIOS) {
      return _openIosStore();
    }

    return false;
  }

  // ============================================================
  // ANDROID STORE
  // ============================================================

  static Future<bool> _openAndroidStore() async {
    final Uri playStoreApp =
    Uri.parse(
      'market://details?id=$_androidPackageName',
    );

    final Uri playStoreWeb =
    Uri.parse(
      'https://play.google.com/store/apps/details?id=$_androidPackageName',
    );

    try {
      final bool opened =
      await launchUrl(
        playStoreApp,
        mode:
        LaunchMode.externalApplication,
      );

      if (opened) {
        return true;
      }
    } catch (_) {}

    try {
      return await launchUrl(
        playStoreWeb,
        mode:
        LaunchMode.externalApplication,
      );
    } catch (_) {
      return false;
    }
  }

  // ============================================================
  // IOS STORE
  // ============================================================

  static Future<bool> _openIosStore() async {
    if (_iosAppStoreId.isEmpty) {
      return false;
    }

    final Uri appStore =
    Uri.parse(
      'https://apps.apple.com/app/id$_iosAppStoreId',
    );

    try {
      return await launchUrl(
        appStore,
        mode:
        LaunchMode.externalApplication,
      );
    } catch (_) {
      return false;
    }
  }
}