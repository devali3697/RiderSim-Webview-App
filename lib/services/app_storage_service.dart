import 'package:shared_preferences/shared_preferences.dart';

class AppStorageService {
  AppStorageService._();

  // ============================================================
  // KEYS
  // ============================================================

  static const String _onboardingCompletedKey =
      'onboarding_completed';

  // Future keys can be added here:
  //
  // static const String _lastAppVersionKey =
  //     'last_app_version';
  //
  // static const String _someSettingKey =
  //     'some_setting';

  // ============================================================
  // ONBOARDING
  // ============================================================

  static Future<bool> isOnboardingCompleted() async {
    final prefs =
    await SharedPreferences.getInstance();

    return prefs.getBool(
      _onboardingCompletedKey,
    ) ??
        false;
  }

  static Future<void> setOnboardingCompleted() async {
    final prefs =
    await SharedPreferences.getInstance();

    await prefs.setBool(
      _onboardingCompletedKey,
      true,
    );
  }

  static Future<void> resetOnboarding() async {
    final prefs =
    await SharedPreferences.getInstance();

    await prefs.remove(
      _onboardingCompletedKey,
    );
  }

  // ============================================================
  // CLEAR ALL APP PREFERENCES
  // ============================================================

  static Future<void> clearAll() async {
    final prefs =
    await SharedPreferences.getInstance();

    await prefs.clear();
  }
}