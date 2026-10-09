import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppDialogs {
  AppDialogs._();

  static const Color _brandRed = Color(0xFFEE0018);
  static const Color _dark = Color(0xFF080808);
  static const Color _gray = Color(0xFF68707B);

  // ============================================================
  // EXIT APP DIALOG
  // ============================================================

  static Future<bool> showExitDialog(
      BuildContext context,
      ) async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          titlePadding: const EdgeInsets.fromLTRB(
            24,
            24,
            24,
            0,
          ),
          contentPadding: const EdgeInsets.fromLTRB(
            24,
            12,
            24,
            0,
          ),
          actionsPadding: const EdgeInsets.fromLTRB(
            16,
            12,
            16,
            16,
          ),
          title: Text(
            'Exit RiderSIM?',
            style: GoogleFonts.inter(
              color: _dark,
              fontSize: 20,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.4,
            ),
          ),
          content: Text(
            'Are you sure you want to close the app?',
            style: GoogleFonts.inter(
              color: _gray,
              fontSize: 14,
              height: 1.5,
              fontWeight: FontWeight.w400,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false);
              },
              style: TextButton.styleFrom(
                foregroundColor: _gray,
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 12,
                ),
              ),
              child: Text(
                'Cancel',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            FilledButton(
              onPressed: () {
                Navigator.of(context).pop(true);
              },
              style: FilledButton.styleFrom(
                backgroundColor: _brandRed,
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(
                  horizontal: 22,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(100),
                ),
              ),
              child: Text(
                'Exit',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        );
      },
    );

    return result ?? false;
  }

  // ============================================================
  // OPTIONAL UPDATE DIALOG
  // ============================================================

  static Future<void> showOptionalUpdateDialog(
      BuildContext context, {
        required String latestVersion,
        required VoidCallback onUpdate,
      }) async {
    await showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          titlePadding: const EdgeInsets.fromLTRB(
            24,
            24,
            24,
            0,
          ),
          contentPadding: const EdgeInsets.fromLTRB(
            24,
            12,
            24,
            0,
          ),
          actionsPadding: const EdgeInsets.fromLTRB(
            16,
            12,
            16,
            16,
          ),
          title: Text(
            'Update Available',
            style: GoogleFonts.inter(
              color: _dark,
              fontSize: 20,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.4,
            ),
          ),
          content: Text(
            'A newer version of RiderSIM ($latestVersion) is available. Update now for the latest improvements.',
            style: GoogleFonts.inter(
              color: _gray,
              fontSize: 14,
              height: 1.5,
              fontWeight: FontWeight.w400,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              style: TextButton.styleFrom(
                foregroundColor: _gray,
              ),
              child: Text(
                'Later',
                style: GoogleFonts.inter(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            FilledButton(
              onPressed: () {
                Navigator.of(context).pop();
                onUpdate();
              },
              style: FilledButton.styleFrom(
                backgroundColor: _brandRed,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(100),
                ),
              ),
              child: Text(
                'Update Now',
                style: GoogleFonts.inter(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  // ============================================================
  // REQUIRED UPDATE DIALOG
  // ============================================================

  static Future<void> showRequiredUpdateDialog(
      BuildContext context, {
        required String latestVersion,
        required VoidCallback onUpdate,
      }) async {
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return PopScope(
          canPop: false,
          child: AlertDialog(
            backgroundColor: Colors.white,
            surfaceTintColor: Colors.transparent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
            titlePadding: const EdgeInsets.fromLTRB(
              24,
              24,
              24,
              0,
            ),
            contentPadding: const EdgeInsets.fromLTRB(
              24,
              12,
              24,
              0,
            ),
            actionsPadding: const EdgeInsets.fromLTRB(
              16,
              12,
              16,
              16,
            ),
            title: Text(
              'Update Required',
              style: GoogleFonts.inter(
                color: _dark,
                fontSize: 20,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.4,
              ),
            ),
            content: Text(
              'This version of RiderSIM is no longer supported. Please update to version $latestVersion to continue.',
              style: GoogleFonts.inter(
                color: _gray,
                fontSize: 14,
                height: 1.5,
                fontWeight: FontWeight.w400,
              ),
            ),
            actions: [
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: onUpdate,
                  style: FilledButton.styleFrom(
                    backgroundColor: _brandRed,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(
                      vertical: 14,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(100),
                    ),
                  ),
                  child: Text(
                    'Update RiderSIM',
                    style: GoogleFonts.inter(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
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

  // ============================================================
  // GENERIC MESSAGE DIALOG
  // ============================================================

  static Future<void> showMessage(
      BuildContext context, {
        required String title,
        required String message,
        String buttonText = 'OK',
      }) async {
    await showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          title: Text(
            title,
            style: GoogleFonts.inter(
              color: _dark,
              fontSize: 20,
              fontWeight: FontWeight.w800,
            ),
          ),
          content: Text(
            message,
            style: GoogleFonts.inter(
              color: _gray,
              fontSize: 14,
              height: 1.5,
            ),
          ),
          actions: [
            FilledButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              style: FilledButton.styleFrom(
                backgroundColor: _brandRed,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(100),
                ),
              ),
              child: Text(
                buttonText,
                style: GoogleFonts.inter(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}