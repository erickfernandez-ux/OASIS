import 'dart:ui';

import 'package:flutter/material.dart';

import 'canvas_theme.dart';

class WatercolorLayer extends StatelessWidget {
  const WatercolorLayer({
    required this.accent,
    required this.theme,
    required this.progress,
    super.key,
  });

  final Color accent;
  final CanvasTheme theme;
  final double progress;

  @override
  Widget build(BuildContext context) {
    final alpha = theme.washOpacity * progress;
    final primary = Color.lerp(theme.primaryTone, accent, 0.3) ?? theme.primaryTone;
    final secondary = Color.lerp(theme.secondaryTone, accent, 0.16) ?? theme.secondaryTone;
    final tertiary = theme.tertiaryTone;

    return Stack(
      fit: StackFit.expand,
      children: [
        Positioned(
          top: -70,
          right: -50,
          child: _WaterBlob(
            accent: primary,
            alpha: alpha,
            size: 260,
            blurSigma: theme.blurSigma,
            xShift: 0.0,
            yShift: 0.0,
          ),
        ),
        Positioned(
          bottom: -100,
          left: -60,
          child: _WaterBlob(
            accent: secondary,
            alpha: alpha * 0.85,
            size: 340,
            blurSigma: theme.blurSigma * 0.9,
            xShift: 0.06,
            yShift: -0.04,
          ),
        ),
        Positioned(
          top: 160,
          left: 20,
          child: _WaterBlob(
            accent: tertiary,
            alpha: alpha * 0.55,
            size: 180,
            blurSigma: theme.blurSigma * 0.7,
            xShift: -0.03,
            yShift: 0.04,
          ),
        ),
      ],
    );
  }
}

class _WaterBlob extends StatelessWidget {
  const _WaterBlob({
    required this.accent,
    required this.alpha,
    required this.size,
    required this.blurSigma,
    required this.xShift,
    required this.yShift,
  });

  final Color accent;
  final double alpha;
  final double size;
  final double blurSigma;
  final double xShift;
  final double yShift;

  @override
  Widget build(BuildContext context) {
    return Transform.translate(
      offset: Offset(size * xShift, size * yShift),
      child: ImageFiltered(
        imageFilter: ImageFilter.blur(sigmaX: blurSigma, sigmaY: blurSigma),
        child: DecoratedBox(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              colors: [
                accent.withValues(alpha: alpha),
                accent.withValues(alpha: alpha * 0.45),
                Colors.transparent,
              ],
            ),
          ),
          child: SizedBox(width: size, height: size),
        ),
      ),
    );
  }
}
