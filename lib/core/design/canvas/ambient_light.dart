import 'package:flutter/material.dart';

import 'canvas_theme.dart';

class AmbientLight extends StatelessWidget {
  const AmbientLight({
    required this.theme,
    required this.progress,
    super.key,
  });

  final CanvasTheme theme;
  final double progress;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              theme.ambientLight.withValues(alpha: 0.2 * progress),
              Colors.transparent,
              theme.tertiaryTone.withValues(alpha: 0.08 * progress),
            ],
            stops: const [0.0, 0.45, 1.0],
          ),
        ),
      ),
    );
  }
}
