import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

class RiderSimOnboardingScreen extends StatefulWidget {
  const RiderSimOnboardingScreen({
    super.key,
    required this.onFinished,
  });

  final VoidCallback onFinished;

  @override
  State<RiderSimOnboardingScreen> createState() =>
      _RiderSimOnboardingScreenState();
}

class _RiderSimOnboardingScreenState
    extends State<RiderSimOnboardingScreen>
    with SingleTickerProviderStateMixin {
  final PageController _pageController = PageController();

  int _currentPage = 0;

  late final AnimationController _entryController;
  late final Animation<double> _fade;
  late final Animation<double> _scale;
  late final Animation<Offset> _slide;

  bool _prepared = false;

  @override
  void initState() {
    super.initState();

    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.edgeToEdge,
    );

    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
        systemNavigationBarColor: Colors.white,
        systemNavigationBarIconBrightness: Brightness.dark,
        systemNavigationBarDividerColor: Colors.transparent,
        systemNavigationBarContrastEnforced: false,
      ),
    );

    _entryController = AnimationController(
      vsync: this,
      duration: const Duration(
        milliseconds: 480,
      ),
    );

    _fade = CurvedAnimation(
      parent: _entryController,
      curve: Curves.easeOut,
    );

    _scale = Tween<double>(
      begin: 0.98,
      end: 1,
    ).animate(
      CurvedAnimation(
        parent: _entryController,
        curve: Curves.easeOutCubic,
      ),
    );

    _slide = Tween<Offset>(
      begin: const Offset(
        0,
        0.025,
      ),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _entryController,
        curve: Curves.easeOutCubic,
      ),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (!_prepared) {
      _prepared = true;
      _prepareAssets();
    }
  }

  Future<void> _prepareAssets() async {
    // Only decode the first screen immediately.
    await precacheImage(
      const AssetImage(
        'assets/images/onboarding_one_icon.png',
      ),
      context,
    );

    if (!mounted) return;

    _entryController.forward();

    // Cache remaining assets AFTER first frame.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      precacheImage(
        const AssetImage(
          'assets/images/onboarding_two_icon.png',
        ),
        context,
      );

      precacheImage(
        const AssetImage(
          'assets/images/onboarding_three_icon.png',
        ),
        context,
      );

      precacheImage(
        const AssetImage(
          'assets/images/thunder_icon.png',
        ),
        context,
      );

      precacheImage(
        const AssetImage(
          'assets/images/globe_icon.png',
        ),
        context,
      );

      precacheImage(
        const AssetImage(
          'assets/images/safe_icon.png',
        ),
        context,
      );
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    _entryController.dispose();
    super.dispose();
  }

  void _restartEntryAnimation() {
    _entryController
      ..reset()
      ..forward();
  }

  Future<void> _next() async {
    if (_currentPage < 2) {
      await _pageController.nextPage(
        duration: const Duration(
          milliseconds: 340,
        ),
        curve: Curves.easeInOutCubic,
      );
    } else {
      widget.onFinished();
    }
  }

  void _skip() {
    widget.onFinished();
  }

  @override
  Widget build(BuildContext context) {
    final bottomSafe =
        MediaQuery.paddingOf(context).bottom;

    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        bottom: false,
        child: LayoutBuilder(
          builder: (
              context,
              constraints,
              ) {
            final width = constraints.maxWidth;
            final height = constraints.maxHeight;

            final bottomAreaHeight =
            (height * 0.15).clamp(
              118.0,
              145.0,
            );

            return Column(
              children: [
                Expanded(
                  child: Stack(
                    children: [
                      PageView(
                        controller: _pageController,
                        physics:
                        const PageScrollPhysics(),
                        onPageChanged: (index) {
                          setState(() {
                            _currentPage = index;
                          });

                          _restartEntryAnimation();
                        },
                        children: [
                          _PageOne(
                            fade: _fade,
                            slide: _slide,
                            scale: _scale,
                          ),
                          _PageTwo(
                            fade: _fade,
                            slide: _slide,
                            scale: _scale,
                          ),
                          _PageThree(
                            fade: _fade,
                            slide: _slide,
                            scale: _scale,
                          ),
                        ],
                      ),

                      Positioned(
                        top: 18,
                        right: 22,
                        child: GestureDetector(
                          behavior:
                          HitTestBehavior.opaque,
                          onTap: _skip,
                          child: Padding(
                            padding:
                            const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 8,
                            ),
                            child: Text(
                              'Skip',
                              style: GoogleFonts.inter(
                                fontSize:
                                (width * 0.046)
                                    .clamp(
                                  16.0,
                                  20.0,
                                ),
                                fontWeight:
                                FontWeight.w400,
                                color:
                                RiderTheme.gray,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(
                  height:
                  bottomAreaHeight +
                      bottomSafe,
                  child: Padding(
                    padding: EdgeInsets.only(
                      left: width * 0.075,
                      right: width * 0.075,
                      bottom:
                      bottomSafe + 14,
                    ),
                    child: Column(
                      mainAxisAlignment:
                      MainAxisAlignment.end,
                      children: [
                        PageDots(
                          currentPage:
                          _currentPage,
                        ),

                        const SizedBox(
                          height: 20,
                        ),

                        RiderButton(
                          text:
                          _currentPage == 2
                              ? 'Get Started'
                              : 'Next',
                          onPressed: _next,
                        ),
                      ],
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

// ===============================================================
// PAGE 1
// ===============================================================

class _PageOne extends StatelessWidget {
  const _PageOne({
    required this.fade,
    required this.slide,
    required this.scale,
  });

  final Animation<double> fade;
  final Animation<Offset> slide;
  final Animation<double> scale;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (
          context,
          constraints,
          ) {
        final width = constraints.maxWidth;
        final height = constraints.maxHeight;

        final compact = height < 650;

        return Padding(
          padding: EdgeInsets.symmetric(
            horizontal: width * 0.085,
          ),
          child: Column(
            crossAxisAlignment:
            CrossAxisAlignment.start,
            children: [
              SizedBox(
                height:
                compact
                    ? 58
                    : 74,
              ),

              FadeTransition(
                opacity: fade,
                child: SlideTransition(
                  position: slide,
                  child: TitleBlock(
                    width: width,
                    lines: const [
                      TitleLine(
                        'Stay',
                        RiderTheme.black,
                      ),
                      TitleLine(
                        'Connected',
                        RiderTheme.red,
                      ),
                      TitleLine(
                        'Worldwide',
                        RiderTheme.black,
                      ),
                    ],
                  ),
                ),
              ),

              SizedBox(
                height:
                compact
                    ? 14
                    : 18,
              ),

              FadeTransition(
                opacity: fade,
                child: Text(
                  'Get instant eSIM data in 190+\ncountries and regions.',
                  style: bodyStyle(
                    width,
                    compact: compact,
                  ),
                ),
              ),

              const SizedBox(
                height: 4,
              ),

              Expanded(
                child: FadeTransition(
                  opacity: fade,
                  child: ScaleTransition(
                    scale: scale,
                    child: RepaintBoundary(
                      child: Image.asset(
                        'assets/images/onboarding_one_icon.png',
                        width: double.infinity,
                        fit: BoxFit.contain,
                        alignment:
                        Alignment.bottomCenter,
                        filterQuality:
                        FilterQuality.low,
                        gaplessPlayback: true,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ===============================================================
// PAGE 2
// ===============================================================

class _PageTwo extends StatelessWidget {
  const _PageTwo({
    required this.fade,
    required this.slide,
    required this.scale,
  });

  final Animation<double> fade;
  final Animation<Offset> slide;
  final Animation<double> scale;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (
          context,
          constraints,
          ) {
        final width = constraints.maxWidth;
        final height = constraints.maxHeight;

        final compact = height < 650;

        return Padding(
          padding: EdgeInsets.symmetric(
            horizontal: width * 0.085,
          ),
          child: Column(
            crossAxisAlignment:
            CrossAxisAlignment.start,
            children: [
              SizedBox(
                height:
                compact
                    ? 58
                    : 74,
              ),

              FadeTransition(
                opacity: fade,
                child: SlideTransition(
                  position: slide,
                  child: TitleBlock(
                    width: width,
                    lines: const [
                      TitleLine(
                        'Fast &',
                        RiderTheme.black,
                      ),
                      TitleLine(
                        'Reliable Data',
                        RiderTheme.red,
                      ),
                    ],
                  ),
                ),
              ),

              SizedBox(
                height:
                compact
                    ? 14
                    : 18,
              ),

              FadeTransition(
                opacity: fade,
                child: Text(
                  'Enjoy high-speed internet\nwherever you go.',
                  style: bodyStyle(
                    width,
                    compact: compact,
                  ),
                ),
              ),

              const SizedBox(
                height: 4,
              ),

              Expanded(
                child: FadeTransition(
                  opacity: fade,
                  child: ScaleTransition(
                    scale: scale,
                    child: RepaintBoundary(
                      child: Image.asset(
                        'assets/images/onboarding_two_icon.png',
                        width: double.infinity,
                        fit: BoxFit.contain,
                        alignment:
                        Alignment.bottomCenter,
                        filterQuality:
                        FilterQuality.low,
                        gaplessPlayback: true,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ===============================================================
// PAGE 3
// ===============================================================

class _PageThree extends StatelessWidget {
  const _PageThree({
    required this.fade,
    required this.slide,
    required this.scale,
  });

  final Animation<double> fade;
  final Animation<Offset> slide;
  final Animation<double> scale;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (
          context,
          constraints,
          ) {
        final width = constraints.maxWidth;
        final height = constraints.maxHeight;

        final compact = height < 680;
        final veryCompact = height < 600;

        return Padding(
          padding: EdgeInsets.symmetric(
            horizontal: width * 0.085,
          ),
          child: Column(
            crossAxisAlignment:
            CrossAxisAlignment.start,
            children: [
              SizedBox(
                height:
                veryCompact
                    ? 50
                    : compact
                    ? 58
                    : 72,
              ),

              FadeTransition(
                opacity: fade,
                child: SlideTransition(
                  position: slide,
                  child: TitleBlock(
                    width: width,
                    lines: const [
                      TitleLine(
                        'Travel',
                        RiderTheme.black,
                      ),
                      TitleLine(
                        'Smarter',
                        RiderTheme.red,
                      ),
                    ],
                  ),
                ),
              ),

              SizedBox(
                height:
                compact
                    ? 12
                    : 16,
              ),

              FadeTransition(
                opacity: fade,
                child: Text(
                  'Easy activation, global coverage\nand secure connection.',
                  style: bodyStyle(
                    width,
                    compact: compact,
                  ),
                ),
              ),

              SizedBox(
                height:
                compact
                    ? 4
                    : 8,
              ),

              Expanded(
                flex:
                compact
                    ? 52
                    : 50,
                child: FadeTransition(
                  opacity: fade,
                  child: ScaleTransition(
                    scale: scale,
                    child: RepaintBoundary(
                      child: Image.asset(
                        'assets/images/onboarding_three_icon.png',
                        width: double.infinity,
                        fit: BoxFit.contain,
                        alignment:
                        Alignment.center,
                        filterQuality:
                        FilterQuality.low,
                        gaplessPlayback: true,
                      ),
                    ),
                  ),
                ),
              ),

              Flexible(
                flex: 40,
                child: FadeTransition(
                  opacity: fade,
                  child: SlideTransition(
                    position: slide,
                    child: Column(
                      mainAxisAlignment:
                      MainAxisAlignment.center,
                      children: [
                        FeatureRow(
                          width: width,
                          compact: compact,
                          image:
                          'assets/images/thunder_icon.png',
                          title:
                          'Easy Activation',
                          description:
                          'Get your eSIM in minutes.',
                        ),

                        SizedBox(
                          height:
                          compact
                              ? 8
                              : 13,
                        ),

                        FeatureRow(
                          width: width,
                          compact: compact,
                          image:
                          'assets/images/globe_icon.png',
                          title:
                          'Global Coverage',
                          description:
                          '190+ countries & regions.',
                        ),

                        SizedBox(
                          height:
                          compact
                              ? 8
                              : 13,
                        ),

                        FeatureRow(
                          width: width,
                          compact: compact,
                          image:
                          'assets/images/safe_icon.png',
                          title:
                          'Safe & Secure',
                          description:
                          'Reliable and private connection.',
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              SizedBox(
                height:
                compact
                    ? 2
                    : 6,
              ),
            ],
          ),
        );
      },
    );
  }
}

// ===============================================================
// TITLE
// ===============================================================

class TitleBlock extends StatelessWidget {
  const TitleBlock({
    super.key,
    required this.width,
    required this.lines,
  });

  final double width;
  final List<TitleLine> lines;

  @override
  Widget build(BuildContext context) {
    final fontSize =
    (width * 0.092).clamp(
      33.0,
      44.0,
    );

    return Column(
      crossAxisAlignment:
      CrossAxisAlignment.start,
      children: lines
          .map(
            (line) => Text(
          line.text,
          maxLines: 1,
          style: GoogleFonts.inter(
            fontSize: fontSize,
            height: 0.98,
            fontWeight:
            FontWeight.w900,
            letterSpacing: -1.8,
            color: line.color,
          ),
        ),
      )
          .toList(),
    );
  }
}

class TitleLine {
  const TitleLine(
      this.text,
      this.color,
      );

  final String text;
  final Color color;
}

// ===============================================================
// FEATURE ROW
// ===============================================================

class FeatureRow extends StatelessWidget {
  const FeatureRow({
    super.key,
    required this.width,
    required this.compact,
    required this.image,
    required this.title,
    required this.description,
  });

  final double width;
  final bool compact;
  final String image;
  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    final iconSize =
    compact
        ? (width * 0.11).clamp(
      40.0,
      48.0,
    )
        : (width * 0.13).clamp(
      48.0,
      58.0,
    );

    return Row(
      crossAxisAlignment:
      CrossAxisAlignment.center,
      children: [
        RepaintBoundary(
          child: Image.asset(
            image,
            width: iconSize,
            height: iconSize,
            fit: BoxFit.contain,
            filterQuality:
            FilterQuality.low,
            gaplessPlayback: true,
          ),
        ),

        SizedBox(
          width: width * 0.035,
        ),

        Expanded(
          child: Column(
            mainAxisSize:
            MainAxisSize.min,
            crossAxisAlignment:
            CrossAxisAlignment.start,
            children: [
              Text(
                title,
                maxLines: 1,
                overflow:
                TextOverflow.ellipsis,
                style: GoogleFonts.inter(
                  fontSize:
                  (width *
                      (compact
                          ? 0.038
                          : 0.042))
                      .clamp(
                    14.5,
                    18.5,
                  ),
                  fontWeight:
                  FontWeight.w800,
                  height: 1.05,
                  color:
                  RiderTheme.black,
                ),
              ),

              const SizedBox(
                height: 3,
              ),

              Text(
                description,
                maxLines: 2,
                overflow:
                TextOverflow.ellipsis,
                style: GoogleFonts.inter(
                  fontSize:
                  (width *
                      (compact
                          ? 0.032
                          : 0.035))
                      .clamp(
                    12.5,
                    15.5,
                  ),
                  height: 1.15,
                  fontWeight:
                  FontWeight.w400,
                  color:
                  RiderTheme.gray,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ===============================================================
// PAGE DOTS
// ===============================================================

class PageDots extends StatelessWidget {
  const PageDots({
    super.key,
    required this.currentPage,
  });

  final int currentPage;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment:
      MainAxisAlignment.center,
      children: List.generate(
        3,
            (index) {
          final active =
              currentPage == index;

          return AnimatedContainer(
            duration: const Duration(
              milliseconds: 160,
            ),
            curve: Curves.easeOut,
            margin:
            const EdgeInsets.symmetric(
              horizontal: 5,
            ),
            width: active ? 13 : 11,
            height: active ? 13 : 11,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color:
              active
                  ? RiderTheme.red
                  : RiderTheme.dotGray,
            ),
          );
        },
      ),
    );
  }
}

// ===============================================================
// BUTTON
// ===============================================================

class RiderButton extends StatefulWidget {
  const RiderButton({
    super.key,
    required this.text,
    required this.onPressed,
  });

  final String text;
  final VoidCallback onPressed;

  @override
  State<RiderButton> createState() =>
      _RiderButtonState();
}

class _RiderButtonState
    extends State<RiderButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final width =
        MediaQuery.sizeOf(context).width;

    final height =
    (width * 0.155).clamp(
      56.0,
      66.0,
    );

    return GestureDetector(
      behavior:
      HitTestBehavior.opaque,

      onTapDown: (_) {
        setState(() {
          _pressed = true;
        });
      },

      onTapCancel: () {
        setState(() {
          _pressed = false;
        });
      },

      onTapUp: (_) {
        setState(() {
          _pressed = false;
        });

        widget.onPressed();
      },

      child: AnimatedScale(
        duration: const Duration(
          milliseconds: 90,
        ),
        curve: Curves.easeOut,
        scale:
        _pressed
            ? 0.985
            : 1,
        child: Container(
          height: height,
          width: double.infinity,
          decoration: BoxDecoration(
            color: RiderTheme.red,
            borderRadius:
            BorderRadius.circular(
              100,
            ),
            boxShadow: [
              BoxShadow(
                color:
                RiderTheme.red
                    .withOpacity(
                  0.15,
                ),
                blurRadius: 16,
                offset:
                const Offset(
                  0,
                  7,
                ),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment:
            MainAxisAlignment.center,
            children: [
              Flexible(
                child: Text(
                  widget.text,
                  maxLines: 1,
                  overflow:
                  TextOverflow.ellipsis,
                  style: GoogleFonts.inter(
                    color: Colors.white,
                    fontSize:
                    (width * 0.046)
                        .clamp(
                      17.0,
                      21.0,
                    ),
                    fontWeight:
                    FontWeight.w700,
                  ),
                ),
              ),

              const SizedBox(
                width: 14,
              ),

              Icon(
                Icons.arrow_forward_rounded,
                color: Colors.white,
                size:
                (width * 0.063)
                    .clamp(
                  23.0,
                  28.0,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ===============================================================
// STYLES
// ===============================================================

TextStyle bodyStyle(
    double width, {
      bool compact = false,
    }) {
  return GoogleFonts.inter(
    fontSize:
    (width *
        (compact
            ? 0.038
            : 0.042))
        .clamp(
      14.5,
      19.0,
    ),
    height: 1.38,
    fontWeight:
    FontWeight.w400,
    color:
    RiderTheme.gray,
    letterSpacing: -0.1,
  );
}

class RiderTheme {
  static const Color red =
  Color(0xFFEE0018);

  static const Color black =
  Color(0xFF070707);

  static const Color gray =
  Color(0xFF5E6570);

  static const Color dotGray =
  Color(0xFFD8D8DB);
}