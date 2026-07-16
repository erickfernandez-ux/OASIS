import 'dart:ui';

import 'package:flutter/material.dart';

import 'motion_spec.dart';

@immutable
class OasisAnimations {
  const OasisAnimations._();

  static const Curve organicCurve = MotionSpec.easeOut;
  static const Duration organicDuration = MotionSpec.fadeIn;
  static const Duration micro = MotionSpec.micro;
  static const Duration staggerStep = MotionSpec.stagger;
}

class OrganicFade extends StatelessWidget {
  const OrganicFade({
    required this.child,
    this.duration = MotionSpec.fadeIn,
    this.beginScale = MotionSpec.beginScale,
    this.endScale = 1.0,
    super.key,
  });

  final Widget child;
  final Duration duration;
  final double beginScale;
  final double endScale;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: 1),
      duration: duration,
      curve: MotionSpec.easeOut,
      child: child,
      builder: (context, value, child) {
        final blur = (1 - value) * MotionSpec.blurBeginning;
        final scale = beginScale + ((endScale - beginScale) * value);
        return Opacity(
          opacity: value,
          child: Transform.scale(
            scale: scale,
            child: ImageFiltered(
              imageFilter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
              child: child,
            ),
          ),
        );
      },
    );
  }
}
