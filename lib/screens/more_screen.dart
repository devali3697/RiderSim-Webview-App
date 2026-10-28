import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class MoreScreen extends StatefulWidget {
  const MoreScreen({
    super.key,
  });

  @override
  State<MoreScreen> createState() =>
      _MoreScreenState();
}

class _MoreScreenState extends State<MoreScreen> {
  // ============================================================
  // COLORS
  // ============================================================

  static const Color _brandRed =
  Color(0xFFEE0018);

  static const Color _background =
  Color(0xFFF7F7F9);

  static const Color _dark =
  Color(0xFF0A0A0B);

  static const Color _gray =
  Color(0xFF6E737B);

  static const Color _divider =
  Color(0xFFE9E9EC);

  // ============================================================
  // URLS
  // ============================================================

  static final Uri _privacyPolicyUri =
  Uri.parse(
    'https://sites.google.com/view/ridersim-privacypolicy',
  );

  static final Uri _websiteUri =
  Uri.parse(
    'https://www.ridersim.com/',
  );

  static final Uri _supportEmailUri =
  Uri(
    scheme: 'mailto',
    path: 'Admin@ridersim.com',
    queryParameters: {
      'subject': 'RiderSIM Support',
    },
  );

  /*
   * IMPORTANT:
   *
   * RiderSIM ki dedicated Terms & Conditions URL
   * jab available ho to sirf is URL ko replace kar dena.
   *
   * Example:
   * https://www.ridersim.com/terms
   *
   * Filhaal RiderSIM website open hogi.
   */
  static final Uri _termsUri =
  Uri.parse(
    'https://www.ridersim.com/',
  );

  // ============================================================
  // APP VERSION
  // ============================================================

  String _versionText = 'Version 1.0.0';

  @override
  void initState() {
    super.initState();

    _loadAppVersion();
  }

  Future<void> _loadAppVersion() async {
    try {
      final info =
      await PackageInfo.fromPlatform();

      if (!mounted) {
        return;
      }

      setState(() {
        _versionText =
        'Version ${info.version} (${info.buildNumber})';
      });
    } catch (_) {
      // Keep fallback version text.
    }
  }

  // ============================================================
  // OPEN URL
  // ============================================================

  Future<void> _openUri(
      Uri uri,
      ) async {
    try {
      final opened =
      await launchUrl(
        uri,
        mode:
        LaunchMode.externalApplication,
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
  // MESSAGE
  // ============================================================

  void _showMessage(
      String message,
      ) {
    if (!mounted) {
      return;
    }

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
  // BUILD
  // ============================================================

  @override
  Widget build(
      BuildContext context,
      ) {
    return Scaffold(
      backgroundColor:
      _background,

      body: SafeArea(
        bottom: false,

        child: CustomScrollView(
          physics:
          const BouncingScrollPhysics(),

          slivers: [
            // ==================================================
            // HEADER
            // ==================================================

            SliverToBoxAdapter(
              child: Padding(
                padding:
                const EdgeInsets.fromLTRB(
                  22,
                  24,
                  22,
                  18,
                ),

                child: Column(
                  crossAxisAlignment:
                  CrossAxisAlignment.start,

                  children: [
                    Text(
                      'More',
                      style:
                      GoogleFonts.inter(
                        fontSize: 30,
                        height: 1.05,
                        fontWeight:
                        FontWeight.w800,
                        letterSpacing: -1.0,
                        color: _dark,
                      ),
                    ),

                    const SizedBox(
                      height: 8,
                    ),

                    Text(
                      'Support, legal information and app details.',
                      style:
                      GoogleFonts.inter(
                        fontSize: 14,
                        height: 1.45,
                        fontWeight:
                        FontWeight.w400,
                        color: _gray,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ==================================================
            // RIDERSIM CARD
            // ==================================================

            SliverToBoxAdapter(
              child: Padding(
                padding:
                const EdgeInsets.symmetric(
                  horizontal: 18,
                ),

                child: Container(
                  width: double.infinity,

                  padding:
                  const EdgeInsets.all(
                    20,
                  ),

                  decoration:
                  BoxDecoration(
                    color: _brandRed,

                    borderRadius:
                    BorderRadius.circular(
                      24,
                    ),

                    boxShadow: [
                      BoxShadow(
                        color:
                        _brandRed.withOpacity(
                          0.16,
                        ),
                        blurRadius: 24,
                        offset:
                        const Offset(
                          0,
                          10,
                        ),
                      ),
                    ],
                  ),

                  child: Row(
                    children: [
                      // ========================================
                      // LOGO
                      // ========================================

                      Container(
                        width: 62,
                        height: 62,

                        padding:
                        const EdgeInsets.all(
                          9,
                        ),

                        decoration:
                        BoxDecoration(
                          color: Colors.white,

                          borderRadius:
                          BorderRadius.circular(
                            18,
                          ),
                        ),

                        child: Image.asset(
                          'assets/images/ridersim_logo.png',
                          fit:
                          BoxFit.contain,
                          filterQuality:
                          FilterQuality.low,
                        ),
                      ),

                      const SizedBox(
                        width: 16,
                      ),

                      // ========================================
                      // TEXT
                      // ========================================

                      Expanded(
                        child: Column(
                          crossAxisAlignment:
                          CrossAxisAlignment.start,

                          children: [
                            Text(
                              'RiderSIM',
                              style:
                              GoogleFonts.inter(
                                color:
                                Colors.white,
                                fontSize: 21,
                                fontWeight:
                                FontWeight.w800,
                                letterSpacing:
                                -0.5,
                              ),
                            ),

                            const SizedBox(
                              height: 5,
                            ),

                            Text(
                              'Travel farther. Stay connected.',
                              style:
                              GoogleFonts.inter(
                                color:
                                Colors.white.withOpacity(
                                  0.88,
                                ),
                                fontSize: 13,
                                height: 1.3,
                                fontWeight:
                                FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // ==================================================
            // HELP & LEGAL TITLE
            // ==================================================

            SliverToBoxAdapter(
              child: _SectionTitle(
                title:
                'Help & Legal',
              ),
            ),

            // ==================================================
            // HELP & LEGAL CARD
            // ==================================================

            SliverToBoxAdapter(
              child: Padding(
                padding:
                const EdgeInsets.symmetric(
                  horizontal: 18,
                ),

                child: _SettingsCard(
                  children: [
                    _SettingsTile(
                      icon:
                      Icons.privacy_tip_outlined,

                      title:
                      'Privacy Policy',

                      subtitle:
                      'Learn how your information is handled',

                      onTap: () {
                        _openUri(
                          _privacyPolicyUri,
                        );
                      },
                    ),

                    const _SettingsDivider(),

                    _SettingsTile(
                      icon:
                      Icons.description_outlined,

                      title:
                      'Terms & Conditions',

                      subtitle:
                      'Review RiderSIM service terms',

                      onTap: () {
                        _openUri(
                          _termsUri,
                        );
                      },
                    ),

                    const _SettingsDivider(),

                    _SettingsTile(
                      icon:
                      Icons.support_agent_rounded,

                      title:
                      'Contact Support',

                      subtitle:
                      'Get help from the RiderSIM team',

                      onTap: () {
                        _openUri(
                          _supportEmailUri,
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),

            // ==================================================
            // RIDERSIM TITLE
            // ==================================================

            SliverToBoxAdapter(
              child: _SectionTitle(
                title:
                'RiderSIM',
              ),
            ),

            // ==================================================
            // RIDERSIM CARD
            // ==================================================

            SliverToBoxAdapter(
              child: Padding(
                padding:
                const EdgeInsets.symmetric(
                  horizontal: 18,
                ),

                child: _SettingsCard(
                  children: [
                    _SettingsTile(
                      icon:
                      Icons.language_rounded,

                      title:
                      'Visit Website',

                      subtitle:
                      'ridersim.com',

                      onTap: () {
                        _openUri(
                          _websiteUri,
                        );
                      },
                    ),

                    const _SettingsDivider(),

                    _SettingsTile(
                      icon:
                      Icons.info_outline_rounded,

                      title:
                      'About RiderSIM',

                      subtitle:
                      'Travel eSIM plans for supported destinations',

                      showArrow:
                      false,
                    ),
                  ],
                ),
              ),
            ),

            // ==================================================
            // VERSION
            // ==================================================

            SliverToBoxAdapter(
              child: Padding(
                padding:
                const EdgeInsets.fromLTRB(
                  22,
                  28,
                  22,
                  8,
                ),

                child: Column(
                  children: [
                    Text(
                      _versionText,
                      textAlign:
                      TextAlign.center,
                      style:
                      GoogleFonts.inter(
                        color: _gray,
                        fontSize: 12.5,
                        fontWeight:
                        FontWeight.w500,
                      ),
                    ),

                    const SizedBox(
                      height: 8,
                    ),

                    Text(
                      '© 2026 RiderSIM',
                      textAlign:
                      TextAlign.center,
                      style:
                      GoogleFonts.inter(
                        color:
                        _gray.withOpacity(
                          0.75,
                        ),
                        fontSize: 11.5,
                        fontWeight:
                        FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SliverToBoxAdapter(
              child: SizedBox(
                height: 110,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ================================================================
// SECTION TITLE
// ================================================================

class _SectionTitle
    extends StatelessWidget {
  const _SectionTitle({
    required this.title,
  });

  final String title;

  @override
  Widget build(
      BuildContext context,
      ) {
    return Padding(
      padding:
      const EdgeInsets.fromLTRB(
        24,
        28,
        24,
        10,
      ),

      child: Text(
        title.toUpperCase(),
        style:
        GoogleFonts.inter(
          color:
          const Color(
            0xFF8A8F96,
          ),
          fontSize: 11.5,
          fontWeight:
          FontWeight.w700,
          letterSpacing: 1.0,
        ),
      ),
    );
  }
}

// ================================================================
// SETTINGS CARD
// ================================================================

class _SettingsCard
    extends StatelessWidget {
  const _SettingsCard({
    required this.children,
  });

  final List<Widget> children;

  @override
  Widget build(
      BuildContext context,
      ) {
    return Container(
      decoration:
      BoxDecoration(
        color:
        Colors.white,

        borderRadius:
        BorderRadius.circular(
          22,
        ),

        border:
        Border.all(
          color:
          const Color(
            0xFFEDEDEF,
          ),
        ),

        boxShadow: [
          BoxShadow(
            color:
            Colors.black.withOpacity(
              0.035,
            ),
            blurRadius: 18,
            offset:
            const Offset(
              0,
              5,
            ),
          ),
        ],
      ),

      child: Column(
        children:
        children,
      ),
    );
  }
}

// ================================================================
// SETTINGS TILE
// ================================================================

class _SettingsTile
    extends StatelessWidget {
  const _SettingsTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.onTap,
    this.showArrow = true,
  });

  final IconData icon;

  final String title;

  final String subtitle;

  final VoidCallback? onTap;

  final bool showArrow;

  static const Color _brandRed =
  Color(0xFFEE0018);

  @override
  Widget build(
      BuildContext context,
      ) {
    return Material(
      color:
      Colors.transparent,

      child: InkWell(
        onTap:
        onTap,

        borderRadius:
        BorderRadius.circular(
          22,
        ),

        child: Padding(
          padding:
          const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 15,
          ),

          child: Row(
            children: [
              // ================================================
              // ICON
              // ================================================

              Container(
                width: 43,
                height: 43,

                decoration:
                BoxDecoration(
                  color:
                  _brandRed.withOpacity(
                    0.08,
                  ),

                  borderRadius:
                  BorderRadius.circular(
                    13,
                  ),
                ),

                child: Icon(
                  icon,
                  color:
                  _brandRed,
                  size: 22,
                ),
              ),

              const SizedBox(
                width: 14,
              ),

              // ================================================
              // TEXT
              // ================================================

              Expanded(
                child: Column(
                  crossAxisAlignment:
                  CrossAxisAlignment.start,

                  children: [
                    Text(
                      title,
                      maxLines: 1,
                      overflow:
                      TextOverflow.ellipsis,

                      style:
                      GoogleFonts.inter(
                        color:
                        const Color(
                          0xFF101114,
                        ),
                        fontSize: 15,
                        fontWeight:
                        FontWeight.w700,
                        letterSpacing:
                        -0.2,
                      ),
                    ),

                    const SizedBox(
                      height: 4,
                    ),

                    Text(
                      subtitle,
                      maxLines: 2,
                      overflow:
                      TextOverflow.ellipsis,

                      style:
                      GoogleFonts.inter(
                        color:
                        const Color(
                          0xFF747982,
                        ),
                        fontSize: 12.5,
                        height: 1.3,
                        fontWeight:
                        FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),

              if (showArrow) ...[
                const SizedBox(
                  width: 10,
                ),

                const Icon(
                  Icons.chevron_right_rounded,
                  color:
                  Color(
                    0xFFB1B4BA,
                  ),
                  size: 24,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

// ================================================================
// DIVIDER
// ================================================================

class _SettingsDivider
    extends StatelessWidget {
  const _SettingsDivider();

  @override
  Widget build(
      BuildContext context,
      ) {
    return const Padding(
      padding:
      EdgeInsets.only(
        left: 73,
      ),

      child: Divider(
        height: 1,
        thickness: 1,
        color:
        Color(
          0xFFEFEFF1,
        ),
      ),
    );
  }
}