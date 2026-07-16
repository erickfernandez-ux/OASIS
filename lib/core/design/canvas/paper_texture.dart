import 'dart:math';

import 'package:flutter/material.dart';

import 'canvas_theme.dart';

class PaperTexture extends StatelessWidget {
  const PaperTexture({
    required this.theme,
    required this.progress,
    super.key,
  });

  final CanvasTheme theme;
  final double progress;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Opacity(
        opacity: theme.noiseOpacity * progress,
        child: CustomPaint(
          painter: _PaperTexturePainter(theme: theme),
          child: const SizedBox.expand(),
        ),
      ),
    );
  }
}

class _PaperTexturePainter extends CustomPainter {
  _PaperTexturePainter({required this.theme}) : _random = Random(42);

  final CanvasTheme theme;
  final Random _random;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.black.withValues(alpha: 0.018);

    for (var index = 0; index < 380; index++) {
      final dx = _random.nextDouble() * size.width;
      final dy = _random.nextDouble() * size.height;
      final radius = 0.35 + _random.nextDouble() * 0.75;
      canvas.drawCircle(Offset(dx, dy), radius, paint);
    }

    final fiberPaint = Paint()
      ..color = theme.paperTint.withValues(alpha: 0.12)
      ..strokeWidth = 0.5
      ..style = PaintingStyle.stroke;

    for (var index = 0; index < 12; index++) {
      final y = (size.height / 12) * index + 10;
      canvas.drawLine(
        Offset(0, y),
        Offset(size.width, y + sin(index * 0.7) * 2),
        fiberPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _PaperTexturePainter oldDelegate) => false;
}
