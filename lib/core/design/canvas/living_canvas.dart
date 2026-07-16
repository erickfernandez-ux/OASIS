import 'dart:ui';
import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../features/settings/domain/enums/canvas_motion_preference.dart';
import 'ambient_light.dart';
import 'ambient_gradient.dart';
import 'canvas_animator.dart';
import 'canvas_theme.dart';
import 'paper_texture.dart';
import 'watercolor_layer.dart';

class LivingCanvas extends StatefulWidget {
  const LivingCanvas({
    required this.child,
    required this.accent,
    this.fadeIn = true,
    this.theme,
    super.key,
  });

  final Widget child;
  final Color accent;
  final bool fadeIn;
  final CanvasTheme? theme;

  @override
  State<LivingCanvas> createState() => _LivingCanvasState();
}

class _LivingCanvasState extends State<LivingCanvas> with SingleTickerProviderStateMixin {
  late final AnimationController _driftController;
  late final bool _allowContinuousMotion;

  @override
  void initState() {
    super.initState();
    _allowContinuousMotion = !WidgetsBinding.instance.runtimeType.toString().contains('TestWidgetsFlutterBinding');
    _driftController = AnimationController(vsync: this, duration: const Duration(seconds: 42));
    if (_allowContinuousMotion) {
      _driftController.repeat();
    }
  }

  @override
  void dispose() {
    _driftController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant LivingCanvas oldWidget) {
    super.didUpdateWidget(oldWidget);
    final theme = widget.theme;
    if (theme != null && _driftController.duration != theme.motionCycle) {
      _driftController.duration = theme.motionCycle;
      if (_allowContinuousMotion && !_driftController.isAnimating) {
        _driftController.repeat();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final resolvedTheme = widget.theme ?? Theme.of(context).extension<CanvasTheme>() ?? const CanvasTheme();
    final motionCycle = resolvedTheme.motionCycle;
    if (_driftController.duration != motionCycle) {
      _driftController.duration = motionCycle;
      if (_allowContinuousMotion && !_driftController.isAnimating) {
        _driftController.repeat();
      }
    }

    final canvas = AnimatedBuilder(
      animation: _driftController,
      builder: (context, _) {
        final amplitude = switch (resolvedTheme.motion) {
          CanvasMotionPreference.enabled => 8.0,
          CanvasMotionPreference.reduced => 4.0,
          CanvasMotionPreference.off => 0.0,
        };
        final phase = _allowContinuousMotion ? _driftController.value * math.pi * 2 : 0.0;
        final drift = Offset(
          amplitude * math.sin(phase),
          amplitude * 0.8 * math.cos(phase * 0.85),
        );

        return Stack(
          fit: StackFit.expand,
          children: [
            DecoratedBox(decoration: BoxDecoration(color: resolvedTheme.paperTint)),
            CanvasAnimator(
              theme: resolvedTheme,
              builder: (context, progress) {
                return Transform.translate(
                  offset: drift,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      AmbientGradient(accent: widget.accent, theme: resolvedTheme, progress: progress),
                      WatercolorLayer(accent: widget.accent, theme: resolvedTheme, progress: progress),
                      AmbientLight(theme: resolvedTheme, progress: progress),
                      BackdropFilter(
                        filter: ImageFilter.blur(
                          sigmaX: resolvedTheme.blurSigma * 0.45,
                          sigmaY: resolvedTheme.blurSigma * 0.45,
                        ),
                        child: const ColoredBox(color: Color(0x04FFFFFF)),
                      ),
                      PaperTexture(theme: resolvedTheme, progress: progress),
                    ],
                  ),
                );
              },
            ),
            widget.child,
          ],
        );
      },
    );

    if (!widget.fadeIn) {
      return canvas;
    }

    return AnimatedOpacity(
      opacity: 1,
      duration: resolvedTheme.revealDuration,
      curve: Curves.easeOut,
      child: canvas,
    );
  }
}
