import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class RetryView extends StatelessWidget {
  const RetryView({
    super.key,
    required this.title,
    required this.description,
    required this.icon,
    required this.onRetry,
    this.onSecondaryAction,
    this.secondaryLabel,
    this.isRetrying = false,
  });

  final String title;
  final String description;

  final IconData icon;

  final VoidCallback onRetry;

  final VoidCallback? onSecondaryAction;
  final String? secondaryLabel;

  final bool isRetrying;

  static const Color _brandRed = Color(0xFFEE0018);
  static const Color _dark = Color(0xFF080808);
  static const Color _gray = Color(0xFF68707B);

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);

    final bool compact =
        size.height < 700;

    return ColoredBox(
      color: Colors.white,
      child: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(
              horizontal:
              size.width * 0.10,
              vertical: 24,
            ),
            child: Column(
              mainAxisSize:
              MainAxisSize.min,
              children: [
                Container(
                  width:
                  compact ? 78 : 92,
                  height:
                  compact ? 78 : 92,
                  decoration:
                  const BoxDecoration(
                    color:
                    Color(0xFFFFECEE),
                    shape:
                    BoxShape.circle,
                  ),
                  child: Icon(
                    icon,
                    color: _brandRed,
                    size:
                    compact ? 38 : 44,
                  ),
                ),

                SizedBox(
                  height:
                  compact ? 20 : 26,
                ),

                Text(
                  title,
                  textAlign:
                  TextAlign.center,
                  style:
                  GoogleFonts.inter(
                    color: _dark,
                    fontSize:
                    compact ? 20 : 23,
                    height: 1.1,
                    fontWeight:
                    FontWeight.w800,
                    letterSpacing: -0.6,
                  ),
                ),

                const SizedBox(
                  height: 12,
                ),

                ConstrainedBox(
                  constraints:
                  const BoxConstraints(
                    maxWidth: 340,
                  ),
                  child: Text(
                    description,
                    textAlign:
                    TextAlign.center,
                    style:
                    GoogleFonts.inter(
                      color: _gray,
                      fontSize:
                      compact ? 14 : 15,
                      height: 1.45,
                      fontWeight:
                      FontWeight.w400,
                    ),
                  ),
                ),

                SizedBox(
                  height:
                  compact ? 24 : 30,
                ),

                SizedBox(
                  width:
                  double.infinity,
                  height: 56,
                  child: FilledButton(
                    onPressed:
                    isRetrying
                        ? null
                        : onRetry,
                    style:
                    FilledButton.styleFrom(
                      backgroundColor:
                      _brandRed,
                      disabledBackgroundColor:
                      _brandRed
                          .withOpacity(
                        0.65,
                      ),
                      foregroundColor:
                      Colors.white,
                      elevation: 0,
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
                      isRetrying
                          ? const SizedBox(
                        key:
                        ValueKey(
                          'loading',
                        ),
                        width: 22,
                        height: 22,
                        child:
                        CircularProgressIndicator(
                          strokeWidth:
                          2.3,
                          color:
                          Colors.white,
                        ),
                      )
                          : Row(
                        key:
                        const ValueKey(
                          'retry',
                        ),
                        mainAxisAlignment:
                        MainAxisAlignment
                            .center,
                        mainAxisSize:
                        MainAxisSize
                            .min,
                        children: [
                          const Icon(
                            Icons
                                .refresh_rounded,
                            size:
                            22,
                          ),
                          const SizedBox(
                            width:
                            8,
                          ),
                          Text(
                            'Try Again',
                            style:
                            GoogleFonts
                                .inter(
                              fontSize:
                              16,
                              fontWeight:
                              FontWeight
                                  .w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                if (
                onSecondaryAction !=
                    null &&
                    secondaryLabel !=
                        null) ...[
                  const SizedBox(
                    height: 12,
                  ),

                  TextButton(
                    onPressed:
                    onSecondaryAction,
                    style:
                    TextButton.styleFrom(
                      foregroundColor:
                      _gray,
                      padding:
                      const EdgeInsets.symmetric(
                        horizontal:
                        16,
                        vertical: 12,
                      ),
                    ),
                    child: Text(
                      secondaryLabel!,
                      style:
                      GoogleFonts.inter(
                        fontSize: 15,
                        fontWeight:
                        FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}