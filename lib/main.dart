import 'package:flutter/material.dart';
import 'package:ridersim_webview_app/screens/main_webview_screen.dart';
import 'package:ridersim_webview_app/screens/onboarding_screen.dart';
import 'package:ridersim_webview_app/screens/splash_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(
    const MyApp(),
  );
}

class MyApp
    extends StatelessWidget {
  const MyApp({
    super.key,
  });

  @override
  Widget build(
      BuildContext context,
      ) {
    return MaterialApp(
      debugShowCheckedModeBanner:
      false,
      title:
      'RiderSIM',
      theme:
      ThemeData(
        useMaterial3:
        true,
        brightness:
        Brightness.light,
        scaffoldBackgroundColor:
        Colors.white,
      ),
      home:
      const AppStartupScreen(),
    );
  }
}

class AppStartupScreen
    extends StatelessWidget {
  const AppStartupScreen({
    super.key,
  });

  @override
  Widget build(
      BuildContext context,
      ) {
    return RiderSimSplashScreen(
      duration:
      const Duration(
        milliseconds: 4500,
      ),
      onFinished: () {
        Navigator.of(
          context,
        ).pushReplacement(
          PageRouteBuilder(
            transitionDuration:
            const Duration(
              milliseconds: 350,
            ),
            pageBuilder: (
                context,
                animation,
                secondaryAnimation,
                ) {
              return RiderSimOnboardingScreen(
                onFinished: () {
                  Navigator.of(
                    context,
                  ).pushReplacement(
                    MaterialPageRoute(
                      builder:
                          (_) =>
                      const MainWebViewScreen(),
                    ),
                  );
                },
              );
            },
            transitionsBuilder: (
                context,
                animation,
                secondaryAnimation,
                child,
                ) {
              return FadeTransition(
                opacity:
                CurvedAnimation(
                  parent:
                  animation,
                  curve:
                  Curves.easeOut,
                ),
                child:
                child,
              );
            },
          ),
        );
      },
    );
  }
}

class HomeScreen
    extends StatelessWidget {
  const HomeScreen({
    super.key,
  });

  @override
  Widget build(
      BuildContext context,
      ) {
    return const Scaffold(
      backgroundColor:
      Colors.white,
      body:
      Center(
        child:
        Text(
          'RiderSIM Home',
          style:
          TextStyle(
            color:
            Colors.black,
            fontSize:
            24,
            fontWeight:
            FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
