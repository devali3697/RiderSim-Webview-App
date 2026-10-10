import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

class RiderSimSplashScreen extends StatefulWidget {
  const RiderSimSplashScreen({
    super.key,
    this.onFinished,
    this.duration = const Duration(
      milliseconds: 4500,
    ),
  });

  final VoidCallback? onFinished;
  final Duration duration;

  @override
  State<RiderSimSplashScreen> createState() =>
      _RiderSimSplashScreenState();
}

class _RiderSimSplashScreenState
    extends State<RiderSimSplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  late final Animation<double> _logoOpacity;
  late final Animation<double> _logoScale;
  late final Animation<Offset> _logoSlide;

  late final Animation<double> _titleOpacity;
  late final Animation<Offset> _titleSlide;

  late final Animation<double> _subtitleOpacity;
  late final Animation<Offset> _subtitleSlide;

  Timer? _timer;

  bool _started = false;

  static const Color brandRed = Color(
    0xFFFF161F,
  );

  @override
  void initState() {
    super.initState();

    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.edgeToEdge,
    );

    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
        systemNavigationBarColor: Colors.transparent,
        systemNavigationBarDividerColor: Colors.transparent,
        systemNavigationBarIconBrightness: Brightness.light,
        systemNavigationBarContrastEnforced: false,
      ),
    );

    // Animation completes quickly.
    // Splash itself stays for 4.5 seconds.
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(
        milliseconds: 1600,
      ),
    );

    // ==============================
    // LOGO OPACITY
    // ==============================

    _logoOpacity = CurvedAnimation(
      parent: _controller,
      curve: const Interval(
        0.00,
        0.35,
        curve: Curves.easeOut,
      ),
    );

    // ==============================
    // LOGO SCALE
    // ==============================

    _logoScale = Tween<double>(
      begin: 0.94,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(
          0.00,
          0.45,
          curve: Curves.easeOutCubic,
        ),
      ),
    );

    // ==============================
    // LOGO SLIDE
    // ==============================

    _logoSlide = Tween<Offset>(
      begin: const Offset(
        0,
        -0.035,
      ),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(
          0.00,
          0.45,
          curve: Curves.easeOutCubic,
        ),
      ),
    );

    // ==============================
    // RIDE THE WORLD
    // ==============================

    _titleOpacity = CurvedAnimation(
      parent: _controller,
      curve: const Interval(
        0.34,
        0.67,
        curve: Curves.easeOut,
      ),
    );

    _titleSlide = Tween<Offset>(
      begin: const Offset(
        0,
        0.16,
      ),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(
          0.30,
          0.72,
          curve: Curves.easeOutCubic,
        ),
      ),
    );

    // ==============================
    // STAY CONNECTED
    // ==============================

    _subtitleOpacity = CurvedAnimation(
      parent: _controller,
      curve: const Interval(
        0.50,
        0.84,
        curve: Curves.easeOut,
      ),
    );

    _subtitleSlide = Tween<Offset>(
      begin: const Offset(
        0,
        0.16,
      ),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(
          0.46,
          0.88,
          curve: Curves.easeOutCubic,
        ),
      ),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (!_started) {
      _started = true;

      _loadAssets();
    }
  }

  Future<void> _loadAssets() async {
    await Future.wait([
      precacheImage(
        const AssetImage(
          'assets/images/ridersim_splash_bg.png',
        ),
        context,
      ),
      precacheImage(
        const AssetImage(
          'assets/images/ridersim_logo.png',
        ),
        context,
      ),
    ]);

    if (!mounted) {
      return;
    }

    // Start animation after images are decoded.
    _controller.forward();

    // Keep screen visible for 4.5 seconds.
    _timer = Timer(
      widget.duration,
          () {
        if (!mounted) {
          return;
        }

        widget.onFinished?.call();
      },
    );
  }

  @override
  void dispose() {
    _timer?.cancel();

    _controller.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(
        0xFF120000,
      ),
      extendBody: true,
      extendBodyBehindAppBar: true,
      body: SizedBox.expand(
        child: LayoutBuilder(
          builder: (
              BuildContext context,
              BoxConstraints constraints,
              ) {
            final double width =
                constraints.maxWidth;

            final double height =
                constraints.maxHeight;

            final double aspect =
                height / width;

            final bool shortPhone =
                aspect < 1.95;

            // ==============================
            // LOGO SIZE
            // ==============================

            final double logoWidth =
            (width *
                (shortPhone
                    ? 0.54
                    : 0.56))
                .clamp(
              205.0,
              310.0,
            );

            final double logoTop =
                height *
                    (shortPhone
                        ? 0.105
                        : 0.115);

            final double logoBottom =
                logoTop + logoWidth;

            // ==============================
            // TEXT POSITION
            // ==============================

            final double headlineGap =
                height * 0.018;

            final double headlineTop =
                logoBottom +
                    headlineGap;

            final double rideFontSize =
            (width * 0.071).clamp(
              27.0,
              37.0,
            );

            final double connectedFontSize =
            (width * 0.073).clamp(
              28.0,
              39.0,
            );

            return Stack(
              fit: StackFit.expand,
              children: [
                // ==============================
                // BACKGROUND
                // ==============================

                RepaintBoundary(
                  child: Image.asset(
                    'assets/images/ridersim_splash_bg.png',
                    width: width,
                    height: height,
                    fit: BoxFit.cover,
                    alignment: Alignment.center,
                    filterQuality:
                    FilterQuality.medium,
                    gaplessPlayback: true,
                  ),
                ),

                // ==============================
                // TOP GRADIENT
                // ==============================

                IgnorePointer(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin:
                        Alignment.topCenter,
                        end: const Alignment(
                          0,
                          -0.15,
                        ),
                        colors: [
                          Colors.black.withOpacity(
                            0.20,
                          ),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                ),

                // ==============================
                // RED GLOW
                // ==============================

                Positioned(
                  top: logoTop,
                  left: width * 0.15,
                  right: width * 0.15,
                  height:
                  logoWidth * 0.78,
                  child: IgnorePointer(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: RadialGradient(
                          colors: [
                            brandRed.withOpacity(
                              0.15,
                            ),
                            brandRed.withOpacity(
                              0.04,
                            ),
                            Colors.transparent,
                          ],
                          stops: const [
                            0.0,
                            0.55,
                            1.0,
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

                // ==============================
                // LOGO
                // ==============================

                Positioned(
                  top: logoTop,
                  left: 0,
                  right: 0,
                  child: FadeTransition(
                    opacity:
                    _logoOpacity,
                    child: SlideTransition(
                      position:
                      _logoSlide,
                      child: ScaleTransition(
                        scale:
                        _logoScale,
                        child: Center(
                          child:
                          RepaintBoundary(
                            child:
                            SizedBox(
                              width:
                              logoWidth,
                              height:
                              logoWidth,
                              child:
                              Image.asset(
                                'assets/images/ridersim_logo.png',
                                fit: BoxFit
                                    .contain,
                                filterQuality:
                                FilterQuality
                                    .medium,
                                gaplessPlayback:
                                true,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                // ==============================
                // HEADLINE
                // ==============================

                Positioned(
                  top: headlineTop,
                  left: width * 0.055,
                  right: width * 0.055,
                  child: Column(
                    mainAxisSize:
                    MainAxisSize.min,
                    children: [
                      FadeTransition(
                        opacity:
                        _titleOpacity,
                        child:
                        SlideTransition(
                          position:
                          _titleSlide,
                          child:
                          _SplashHeadline(
                            text:
                            'RIDE THE WORLD',
                            fontSize:
                            rideFontSize,
                            color:
                            Colors.white,
                            shadowColor:
                            const Color(
                              0xB0000000,
                            ),
                          ),
                        ),
                      ),

                      SizedBox(
                        height:
                        height *
                            0.003,
                      ),

                      FadeTransition(
                        opacity:
                        _subtitleOpacity,
                        child:
                        SlideTransition(
                          position:
                          _subtitleSlide,
                          child:
                          _SplashHeadline(
                            text:
                            'STAY CONNECTED',
                            fontSize:
                            connectedFontSize,
                            color:
                            brandRed,
                            shadowColor:
                            const Color(
                              0xFF650000,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // ==============================
                // BOTTOM VIGNETTE
                // ==============================

                IgnorePointer(
                  child: Align(
                    alignment:
                    Alignment
                        .bottomCenter,
                    child: Container(
                      height:
                      height *
                          0.10,
                      decoration:
                      BoxDecoration(
                        gradient:
                        LinearGradient(
                          begin:
                          Alignment
                              .topCenter,
                          end:
                          Alignment
                              .bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black
                                .withOpacity(
                              0.12,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _SplashHeadline
    extends StatelessWidget {
  const _SplashHeadline({
    required this.text,
    required this.fontSize,
    required this.color,
    required this.shadowColor,
  });

  final String text;
  final double fontSize;
  final Color color;
  final Color shadowColor;

  @override
  Widget build(
      BuildContext context,
      ) {
    return FittedBox(
      fit: BoxFit.scaleDown,
      child: Text(
        text,
        maxLines: 1,
        textAlign:
        TextAlign.center,
        style:
        GoogleFonts.montserrat(
          fontSize:
          fontSize,
          height:
          0.96,
          fontWeight:
          FontWeight.w900,
          letterSpacing:
          -0.8,
          color:
          color,
          shadows: [
            Shadow(
              color:
              shadowColor,
              blurRadius:
              2,
              offset:
              const Offset(
                0,
                3,
              ),
            ),
          ],
        ),
      ),
    );
  }
}