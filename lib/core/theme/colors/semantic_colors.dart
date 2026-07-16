import 'package:flutter/material.dart';
import 'primitive_colors.dart';

/// Semantic colors of the system.
/// Describe purpose, not appearance.
@immutable
class SemanticColors extends ThemeExtension<SemanticColors> {
  final Color primary;
  final Color onPrimary;
  final Color secondary;
  final Color onSecondary;
  final Color accent;
  final Color onAccent;
  final Color success;
  final Color onSuccess;
  final Color warning;
  final Color onWarning;
  final Color error;
  final Color onError;
  final Color info;
  final Color onInfo;
  final Color background;
  final Color onBackground;
  final Color surface;
  final Color onSurface;
  final Color surfaceVariant;
  final Color onSurfaceVariant;
  final Color outline;
  final Color divider;
  final Color textPrimary;
  final Color textSecondary;
  final Color textDisabled;

  const SemanticColors({
    required this.primary,
    required this.onPrimary,
    required this.secondary,
    required this.onSecondary,
    required this.accent,
    required this.onAccent,
    required this.success,
    required this.onSuccess,
    required this.warning,
    required this.onWarning,
    required this.error,
    required this.onError,
    required this.info,
    required this.onInfo,
    required this.background,
    required this.onBackground,
    required this.surface,
    required this.onSurface,
    required this.surfaceVariant,
    required this.onSurfaceVariant,
    required this.outline,
    required this.divider,
    required this.textPrimary,
    required this.textSecondary,
    required this.textDisabled,
  });

  factory SemanticColors.light() {
    return const SemanticColors(
      primary: PrimitiveColors.moss,
      onPrimary: PrimitiveColors.paper,
      secondary: PrimitiveColors.sand,
      onSecondary: PrimitiveColors.ink,
      accent: PrimitiveColors.clay,
      onAccent: PrimitiveColors.paper,
      success: PrimitiveColors.forest,
      onSuccess: PrimitiveColors.paper,
      warning: PrimitiveColors.amber,
      onWarning: PrimitiveColors.ink,
      error: PrimitiveColors.rose,
      onError: PrimitiveColors.paper,
      info: PrimitiveColors.sky,
      onInfo: PrimitiveColors.paper,
      background: PrimitiveColors.stone,
      onBackground: PrimitiveColors.ink,
      surface: PrimitiveColors.paper,
      onSurface: PrimitiveColors.ink,
      surfaceVariant: PrimitiveColors.stone,
      onSurfaceVariant: PrimitiveColors.fog,
      outline: PrimitiveColors.cloud,
      divider: PrimitiveColors.cloud,
      textPrimary: PrimitiveColors.ink,
      textSecondary: PrimitiveColors.fog,
      textDisabled: PrimitiveColors.mist,
    );
  }

  factory SemanticColors.dark() {
    return const SemanticColors(
      primary: PrimitiveColors.sage,
      onPrimary: PrimitiveColors.ink,
      secondary: PrimitiveColors.sandDark,
      onSecondary: PrimitiveColors.paper,
      accent: PrimitiveColors.clayLight,
      onAccent: PrimitiveColors.ink,
      success: PrimitiveColors.forestLight,
      onSuccess: PrimitiveColors.ink,
      warning: PrimitiveColors.amberLight,
      onWarning: PrimitiveColors.ink,
      error: PrimitiveColors.roseLight,
      onError: PrimitiveColors.ink,
      info: PrimitiveColors.skyLight,
      onInfo: PrimitiveColors.ink,
      background: PrimitiveColors.ink,
      onBackground: PrimitiveColors.paper,
      surface: PrimitiveColors.charcoal,
      onSurface: PrimitiveColors.paper,
      surfaceVariant: PrimitiveColors.charcoal,
      onSurfaceVariant: PrimitiveColors.mist,
      outline: PrimitiveColors.fog,
      divider: PrimitiveColors.fog,
      textPrimary: PrimitiveColors.stone,
      textSecondary: PrimitiveColors.mist,
      textDisabled: PrimitiveColors.fog,
    );
  }

  factory SemanticColors.highContrastLight() {
    return SemanticColors.light().copyWith(
      textPrimary: PrimitiveColors.ink,
      textSecondary: PrimitiveColors.charcoal,
      outline: PrimitiveColors.ink,
      divider: PrimitiveColors.ink,
    );
  }

  factory SemanticColors.highContrastDark() {
    return SemanticColors.dark().copyWith(
      textPrimary: PrimitiveColors.paper,
      textSecondary: PrimitiveColors.stone,
      outline: PrimitiveColors.paper,
      divider: PrimitiveColors.paper,
    );
  }

  @override
  SemanticColors copyWith({
    Color? primary,
    Color? onPrimary,
    Color? secondary,
    Color? onSecondary,
    Color? accent,
    Color? onAccent,
    Color? success,
    Color? onSuccess,
    Color? warning,
    Color? onWarning,
    Color? error,
    Color? onError,
    Color? info,
    Color? onInfo,
    Color? background,
    Color? onBackground,
    Color? surface,
    Color? onSurface,
    Color? surfaceVariant,
    Color? onSurfaceVariant,
    Color? outline,
    Color? divider,
    Color? textPrimary,
    Color? textSecondary,
    Color? textDisabled,
  }) {
    return SemanticColors(
      primary: primary ?? this.primary,
      onPrimary: onPrimary ?? this.onPrimary,
      secondary: secondary ?? this.secondary,
      onSecondary: onSecondary ?? this.onSecondary,
      accent: accent ?? this.accent,
      onAccent: onAccent ?? this.onAccent,
      success: success ?? this.success,
      onSuccess: onSuccess ?? this.onSuccess,
      warning: warning ?? this.warning,
      onWarning: onWarning ?? this.onWarning,
      error: error ?? this.error,
      onError: onError ?? this.onError,
      info: info ?? this.info,
      onInfo: onInfo ?? this.onInfo,
      background: background ?? this.background,
      onBackground: onBackground ?? this.onBackground,
      surface: surface ?? this.surface,
      onSurface: onSurface ?? this.onSurface,
      surfaceVariant: surfaceVariant ?? this.surfaceVariant,
      onSurfaceVariant: onSurfaceVariant ?? this.onSurfaceVariant,
      outline: outline ?? this.outline,
      divider: divider ?? this.divider,
      textPrimary: textPrimary ?? this.textPrimary,
      textSecondary: textSecondary ?? this.textSecondary,
      textDisabled: textDisabled ?? this.textDisabled,
    );
  }

  @override
  SemanticColors lerp(ThemeExtension<SemanticColors>? other, double t) {
    if (other is! SemanticColors) return this;
    return SemanticColors(
      primary: Color.lerp(primary, other.primary, t)!,
      onPrimary: Color.lerp(onPrimary, other.onPrimary, t)!,
      secondary: Color.lerp(secondary, other.secondary, t)!,
      onSecondary: Color.lerp(onSecondary, other.onSecondary, t)!,
      accent: Color.lerp(accent, other.accent, t)!,
      onAccent: Color.lerp(onAccent, other.onAccent, t)!,
      success: Color.lerp(success, other.success, t)!,
      onSuccess: Color.lerp(onSuccess, other.onSuccess, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
      onWarning: Color.lerp(onWarning, other.onWarning, t)!,
      error: Color.lerp(error, other.error, t)!,
      onError: Color.lerp(onError, other.onError, t)!,
      info: Color.lerp(info, other.info, t)!,
      onInfo: Color.lerp(onInfo, other.onInfo, t)!,
      background: Color.lerp(background, other.background, t)!,
      onBackground: Color.lerp(onBackground, other.onBackground, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      onSurface: Color.lerp(onSurface, other.onSurface, t)!,
      surfaceVariant: Color.lerp(surfaceVariant, other.surfaceVariant, t)!,
      onSurfaceVariant: Color.lerp(onSurfaceVariant, other.onSurfaceVariant, t)!,
      outline: Color.lerp(outline, other.outline, t)!,
      divider: Color.lerp(divider, other.divider, t)!,
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
      textDisabled: Color.lerp(textDisabled, other.textDisabled, t)!,
    );
  }
}
