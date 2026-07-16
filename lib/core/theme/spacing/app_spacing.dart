import 'package:flutter/material.dart';
import 'dart:ui';

/// Spacing system based on multiples of 4.
/// Never use numeric values directly in widgets.
@immutable
class AppSpacing extends ThemeExtension<AppSpacing> {
  final double xs;
  final double sm;
  final double md;
  final double lg;
  final double xl;
  final double xxl;
  final EdgeInsets paddingSmall;
  final EdgeInsets paddingMedium;
  final EdgeInsets paddingLarge;

  const AppSpacing({
    required this.xs,
    required this.sm,
    required this.md,
    required this.lg,
    required this.xl,
    required this.xxl,
    required this.paddingSmall,
    required this.paddingMedium,
    required this.paddingLarge,
  });

  factory AppSpacing.defaultSpacing() {
    return const AppSpacing(
      xs: 4,
      sm: 8,
      md: 16,
      lg: 24,
      xl: 32,
      xxl: 48,
      paddingSmall: EdgeInsets.all(8),
      paddingMedium: EdgeInsets.all(16),
      paddingLarge: EdgeInsets.all(24),
    );
  }

  @override
  AppSpacing copyWith({
    double? xs,
    double? sm,
    double? md,
    double? lg,
    double? xl,
    double? xxl,
    EdgeInsets? paddingSmall,
    EdgeInsets? paddingMedium,
    EdgeInsets? paddingLarge,
  }) {
    return AppSpacing(
      xs: xs ?? this.xs,
      sm: sm ?? this.sm,
      md: md ?? this.md,
      lg: lg ?? this.lg,
      xl: xl ?? this.xl,
      xxl: xxl ?? this.xxl,
      paddingSmall: paddingSmall ?? this.paddingSmall,
      paddingMedium: paddingMedium ?? this.paddingMedium,
      paddingLarge: paddingLarge ?? this.paddingLarge,
    );
  }

  @override
  AppSpacing lerp(ThemeExtension<AppSpacing>? other, double t) {
    if (other is! AppSpacing) return this;
    return AppSpacing(
      xs: lerpDouble(xs, other.xs, t)!,
      sm: lerpDouble(sm, other.sm, t)!,
      md: lerpDouble(md, other.md, t)!,
      lg: lerpDouble(lg, other.lg, t)!,
      xl: lerpDouble(xl, other.xl, t)!,
      xxl: lerpDouble(xxl, other.xxl, t)!,
      paddingSmall: EdgeInsets.lerp(paddingSmall, other.paddingSmall, t)!,
      paddingMedium: EdgeInsets.lerp(paddingMedium, other.paddingMedium, t)!,
      paddingLarge: EdgeInsets.lerp(paddingLarge, other.paddingLarge, t)!,
    );
  }
}
