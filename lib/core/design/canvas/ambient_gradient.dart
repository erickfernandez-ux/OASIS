import 'package:flutter/material.dart';

import 'canvas_theme.dart';

class AmbientGradient extends StatelessWidget {
  const AmbientGradient({
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
    final accentSoft = Color.lerp(theme.primaryTone, accent, 0.25)?.withValues(alpha: theme.gradientStrength * progress) ??
        theme.primaryTone.withValues(alpha: theme.gradientStrength * progress);
    final accentDistant =
        theme.secondaryTone.withValues(alpha: theme.gradientStrength * 0.55 * progress);

    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: RadialGradient(
          center: const Alignment(-0.8, -0.8),
          radius: 1.2,
          colors: [
            theme.paperTint,
            Color.lerp(theme.paperTint, accentSoft, 0.18) ?? theme.paperTint,
            Color.lerp(theme.paperTint, accentDistant, 0.36) ?? theme.paperTint,
            theme.tertiaryTone.withValues(alpha: 0.4),
          ],
          stops: const [0, 0.34, 0.7, 1],
        ),
      ),
    );
  }
}
