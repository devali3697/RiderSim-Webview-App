import 'package:flutter/material.dart';

class WebLoadingBar extends StatelessWidget {
  const WebLoadingBar({
    super.key,
    required this.progress,
    this.visible = true,
  });

  final double progress;
  final bool visible;

  static const Color _brandRed = Color(0xFFEE0018);

  @override
  Widget build(BuildContext context) {
    final normalizedProgress =
    progress.clamp(0.0, 1.0);

    return IgnorePointer(
      child: AnimatedOpacity(
        opacity: visible ? 1 : 0,
        duration: const Duration(
          milliseconds: 180,
        ),
        curve: Curves.easeOut,
        child: SizedBox(
          height: 3,
          width: double.infinity,
          child: Stack(
            children: [
              Container(
                width: double.infinity,
                color: Colors.transparent,
              ),
              AnimatedFractionallySizedBox(
                duration: const Duration(
                  milliseconds: 180,
                ),
                curve: Curves.easeOutCubic,
                alignment: Alignment.centerLeft,
                widthFactor: normalizedProgress,
                child: const ColoredBox(
                  color: _brandRed,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}