import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:ridersim_webview_app/screens/onboarding_screen.dart';
import 'package:ridersim_webview_app/screens/splash_screen.dart';

import 'screens/main_webview_screen.dart';
import 'services/app_storage_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ============================================================
  // INITIAL SYSTEM UI
  // ============================================================

  SystemChrome.setEnabledSystemUIMode(
    SystemUiMode.edgeToEdge,
  );

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      statusBarBrightness: Brightness.dark,
      systemNavigationBarColor: Colors.black,
      systemNavigationBarIconBrightness: Brightness.light,
      systemNavigationBarDividerColor: Colors.transparent,
      systemNavigationBarContrastEnforced: false,
    ),
  );

  // ============================================================
  // START APP
  // ============================================================

  runApp(
    const RiderSimApp(),
  );
}

// ============================================================
// ROOT APP
// ============================================================

class RiderSimApp extends StatelessWidget {
  const RiderSimApp({
    super.key,
  });

  static const Color brandRed =
  Color(0xFFEE0018);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'RiderSIM',

      debugShowCheckedModeBanner: false,

      theme: ThemeData(
        useMaterial3: true,

        colorScheme: ColorScheme.fromSeed(
          seedColor: brandRed,
          brightness: Brightness.light,
        ),

        scaffoldBackgroundColor: Colors.white,

        splashFactory: InkRipple.splashFactory,

        pageTransitionsTheme:
        const PageTransitionsTheme(
          builders: {
            TargetPlatform.android:
            CupertinoPageTransitionsBuilder(),

            TargetPlatform.iOS:
            CupertinoPageTransitionsBuilder(),
          },
        ),
      ),

      home: const AppStartupScreen(),
    );
  }
}

// ============================================================
// APP STARTUP STAGES
// ============================================================

enum _AppStage {
  splash,
  onboarding,
  main,
}

// ============================================================
// STARTUP SCREEN
// ============================================================

class AppStartupScreen extends StatefulWidget {
  const AppStartupScreen({
    super.key,
  });

  @override
  State<AppStartupScreen> createState() =>
      _AppStartupScreenState();
}

class _AppStartupScreenState
    extends State<AppStartupScreen> {
  // ============================================================
  // CURRENT APP STAGE
  // ============================================================

  _AppStage _stage =
      _AppStage.splash;

  // ============================================================
  // ONBOARDING STATUS
  // ============================================================

  bool? _onboardingCompleted;

  // Prevents Skip / Get Started from being triggered twice.
  bool _isFinishingOnboarding =
  false;

  // Prevent splash callback from running twice.
  bool _splashHandled =
  false;

  // ============================================================
  // INIT
  // ============================================================

  @override
  void initState() {
    super.initState();

    /*
     * Load SharedPreferences immediately
     * while splash screen is still running.
     *
     * This does NOT need internet.
     */
    _loadStartupData();
  }

  // ============================================================
  // LOAD STARTUP DATA
  // ============================================================

  Future<void> _loadStartupData() async {
    try {
      final completed =
      await AppStorageService
          .isOnboardingCompleted();

      if (!mounted) {
        return;
      }

      _onboardingCompleted =
          completed;
    } catch (_) {
      /*
       * If SharedPreferences fails for any reason,
       * safe fallback is to show onboarding.
       */

      if (!mounted) {
        return;
      }

      _onboardingCompleted =
      false;
    }
  }

  // ============================================================
  // SPLASH FINISHED
  // ============================================================

  Future<void>
  _handleSplashFinished() async {
    // Prevent duplicate callback.
    if (_splashHandled) {
      return;
    }

    _splashHandled =
    true;

    /*
     * Normally onboarding state has already loaded
     * during the 4.5 second splash.
     *
     * But if it has not completed yet,
     * wait/read it here again safely.
     */

    if (_onboardingCompleted ==
        null) {
      try {
        _onboardingCompleted =
        await AppStorageService
            .isOnboardingCompleted();
      } catch (_) {
        _onboardingCompleted =
        false;
      }
    }

    if (!mounted) {
      return;
    }

    // ==========================================================
    // DECIDE WHERE TO GO
    // ==========================================================

    setState(() {
      if (_onboardingCompleted ==
          true) {
        _stage =
            _AppStage.main;
      } else {
        _stage =
            _AppStage.onboarding;
      }
    });
  }

  // ============================================================
  // ONBOARDING FINISHED
  // ============================================================

  Future<void>
  _handleOnboardingFinished() async {
    /*
     * Prevent:
     *
     * - double taps
     * - Skip + Next overlapping
     * - accidental multiple callbacks
     */

    if (_isFinishingOnboarding) {
      return;
    }

    _isFinishingOnboarding =
    true;

    // ==========================================================
    // SAVE ONBOARDING COMPLETION
    // ==========================================================
    //
    // This is LOCAL storage.
    //
    // Internet is NOT required.
    // ==========================================================

    try {
      await AppStorageService
          .setOnboardingCompleted();
    } catch (_) {
      /*
       * IMPORTANT:
       *
       * Even if local saving fails,
       * NEVER leave user stuck on onboarding.
       *
       * We still continue to MainWebViewScreen.
       */
    }

    if (!mounted) {
      return;
    }

    // ==========================================================
    // MOVE DIRECTLY TO MAIN APP
    // ==========================================================
    //
    // No Navigator pushReplacement here.
    //
    // We simply change current app stage.
    //
    // This avoids the disposed-parent callback bug.
    // ==========================================================

    setState(() {
      _onboardingCompleted =
      true;

      _stage =
          _AppStage.main;
    });

    _isFinishingOnboarding =
    false;
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(
      BuildContext context,
      ) {
    switch (_stage) {
    // ========================================================
    // SPLASH
    // ========================================================

      case _AppStage.splash:
        return RiderSimSplashScreen(
          onFinished:
          _handleSplashFinished,
        );

    // ========================================================
    // ONBOARDING
    // ========================================================

      case _AppStage.onboarding:
        return RiderSimOnboardingScreen(
          onFinished:
          _handleOnboardingFinished,
        );

    // ========================================================
    // MAIN RIDERSIM APP
    // ========================================================

      case _AppStage.main:
        return const MainWebViewScreen();
    }
  }
}