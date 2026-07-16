import 'dart:ui';

import 'package:flutter/material.dart';

import '../../../features/settings/domain/enums/canvas_intensity_preference.dart';
import '../../../features/settings/domain/enums/canvas_motion_preference.dart';
import '../../../features/settings/domain/enums/canvas_style_preference.dart';

@immutable
class CanvasTheme extends ThemeExtension<CanvasTheme> {
  const CanvasTheme({
    this.style = CanvasStylePreference.forest,
    this.intensity = CanvasIntensityPreference.subtle,
    this.motion = CanvasMotionPreference.enabled,
    this.primaryTone = const Color(0xFF91A58C),
    this.secondaryTone = const Color(0xFFA8B48A),
    this.tertiaryTone = const Color(0xFFF5F1E8),
    this.ambientLight = const Color(0xFFFFFBF3),
    this.washOpacity = 0.18,
    this.noiseOpacity = 0.045,
    this.blurSigma = 22,
    this.revealDuration = const Duration(seconds: 4),
    this.gradientStrength = 0.28,
    this.paperTint = const Color(0xFFF9F5EF),
  });

  final CanvasStylePreference style;
  final CanvasIntensityPreference intensity;
  final CanvasMotionPreference motion;
  final Color primaryTone;
  final Color secondaryTone;
  final Color tertiaryTone;
  final Color ambientLight;
  final double washOpacity;
  final double noiseOpacity;
  final double blurSigma;
  final Duration revealDuration;
  final double gradientStrength;
  final Color paperTint;

  Duration get motionCycle => switch (motion) {
        CanvasMotionPreference.enabled => const Duration(seconds: 42),
        CanvasMotionPreference.reduced => const Duration(seconds: 56),
        CanvasMotionPreference.off => const Duration(seconds: 60),
      };

  factory CanvasTheme.fromPreferences({
    required CanvasStylePreference style,
    required CanvasIntensityPreference intensity,
    required CanvasMotionPreference motion,
  }) {
    final intensityConfig = switch (intensity) {
      CanvasIntensityPreference.verySubtle => (wash: 0.12, noise: 0.03, blur: 18.0, gradient: 0.20, tint: const Color(0xFFFBF8F3)),
      CanvasIntensityPreference.subtle => (wash: 0.18, noise: 0.045, blur: 22.0, gradient: 0.28, tint: const Color(0xFFF9F5EF)),
      CanvasIntensityPreference.medium => (wash: 0.26, noise: 0.06, blur: 28.0, gradient: 0.36, tint: const Color(0xFFF6F1E8)),
    };

    final palette = switch (style) {
      CanvasStylePreference.forest => (
          primary: const Color(0xFF91A58C),
          secondary: const Color(0xFFA8B48A),
          tertiary: const Color(0xFFF5F1E8),
          light: const Color(0xFFFFFBF3),
        ),
      CanvasStylePreference.mist => (
          primary: const Color(0xFF6E808D),
          secondary: const Color(0xFF9A95AE),
          tertiary: const Color(0xFF98A4AF),
          light: const Color(0xFFF4F5FA),
        ),
      CanvasStylePreference.linen => (
          primary: const Color(0xFFC9B69D),
          secondary: const Color(0xFFD9CBB6),
          tertiary: const Color(0xFFF2E9D9),
          light: const Color(0xFFFFF6E8),
        ),
      CanvasStylePreference.coast => (
          primary: const Color(0xFF8EA2B2),
          secondary: const Color(0xFFD9CCB8),
          tertiary: const Color(0xFFEDEBE7),
          light: const Color(0xFFF5F8FA),
        ),
      CanvasStylePreference.sereneNight => (
          primary: const Color(0xFF3B3A43),
          secondary: const Color(0xFF5B5764),
          tertiary: const Color(0xFF6A6762),
          light: const Color(0xFFE1D3C7),
        ),
    };

    return CanvasTheme(
      style: style,
      intensity: intensity,
      motion: motion,
      primaryTone: palette.primary,
      secondaryTone: palette.secondary,
      tertiaryTone: palette.tertiary,
      ambientLight: palette.light,
      washOpacity: intensityConfig.wash,
      noiseOpacity: intensityConfig.noise,
      blurSigma: intensityConfig.blur,
      gradientStrength: intensityConfig.gradient,
      paperTint: intensityConfig.tint,
      revealDuration: const Duration(seconds: 4),
    );
  }

  @override
  CanvasTheme copyWith({
    CanvasStylePreference? style,
    CanvasIntensityPreference? intensity,
    CanvasMotionPreference? motion,
    Color? primaryTone,
    Color? secondaryTone,
    Color? tertiaryTone,
    Color? ambientLight,
    double? washOpacity,
    double? noiseOpacity,
    double? blurSigma,
    Duration? revealDuration,
    double? gradientStrength,
    Color? paperTint,
  }) {
    return CanvasTheme(
      style: style ?? this.style,
      intensity: intensity ?? this.intensity,
      motion: motion ?? this.motion,
      primaryTone: primaryTone ?? this.primaryTone,
      secondaryTone: secondaryTone ?? this.secondaryTone,
      tertiaryTone: tertiaryTone ?? this.tertiaryTone,
      ambientLight: ambientLight ?? this.ambientLight,
      washOpacity: washOpacity ?? this.washOpacity,
      noiseOpacity: noiseOpacity ?? this.noiseOpacity,
      blurSigma: blurSigma ?? this.blurSigma,
      revealDuration: revealDuration ?? this.revealDuration,
      gradientStrength: gradientStrength ?? this.gradientStrength,
      paperTint: paperTint ?? this.paperTint,
    );
  }

  @override
  CanvasTheme lerp(ThemeExtension<CanvasTheme>? other, double t) {
    if (other is! CanvasTheme) return this;
    return CanvasTheme(
      style: t < 0.5 ? style : other.style,
      intensity: t < 0.5 ? intensity : other.intensity,
      motion: t < 0.5 ? motion : other.motion,
      primaryTone: Color.lerp(primaryTone, other.primaryTone, t) ?? primaryTone,
      secondaryTone: Color.lerp(secondaryTone, other.secondaryTone, t) ?? secondaryTone,
      tertiaryTone: Color.lerp(tertiaryTone, other.tertiaryTone, t) ?? tertiaryTone,
      ambientLight: Color.lerp(ambientLight, other.ambientLight, t) ?? ambientLight,
      washOpacity: lerpDouble(washOpacity, other.washOpacity, t) ?? washOpacity,
      noiseOpacity: lerpDouble(noiseOpacity, other.noiseOpacity, t) ?? noiseOpacity,
      blurSigma: lerpDouble(blurSigma, other.blurSigma, t) ?? blurSigma,
      revealDuration: t < 0.5 ? revealDuration : other.revealDuration,
      gradientStrength: lerpDouble(gradientStrength, other.gradientStrength, t) ?? gradientStrength,
      paperTint: Color.lerp(paperTint, other.paperTint, t) ?? paperTint,
    );
  }
}
