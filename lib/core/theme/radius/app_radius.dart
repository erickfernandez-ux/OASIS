import 'package:flutter/material.dart';

/// Reusable border radii.
@immutable
class AppRadius extends ThemeExtension<AppRadius> {
  final BorderRadius small;
  final BorderRadius medium;
  final BorderRadius large;
  final BorderRadius xl;
  final BorderRadius xxl;
  final BorderRadius pill;

  const AppRadius({
    required this.small,
    required this.medium,
    required this.large,
    required this.xl,
    required this.xxl,
    required this.pill,
  });

  factory AppRadius.defaultRadius() {
    return const AppRadius(
      small: BorderRadius.all(Radius.circular(4)),
      medium: BorderRadius.all(Radius.circular(8)),
      large: BorderRadius.all(Radius.circular(12)),
      xl: BorderRadius.all(Radius.circular(16)),
      xxl: BorderRadius.all(Radius.circular(24)),
      pill: BorderRadius.all(Radius.circular(32)),
    );
  }

  @override
  AppRadius copyWith({
    BorderRadius? small,
    BorderRadius? medium,
    BorderRadius? large,
    BorderRadius? xl,
    BorderRadius? xxl,
    BorderRadius? pill,
  }) {
    return AppRadius(
      small: small ?? this.small,
      medium: medium ?? this.medium,
      large: large ?? this.large,
      xl: xl ?? this.xl,
      xxl: xxl ?? this.xxl,
      pill: pill ?? this.pill,
    );
  }

  @override
  AppRadius lerp(ThemeExtension<AppRadius>? other, double t) {
    if (other is! AppRadius) return this;
    return AppRadius(
      small: BorderRadius.lerp(small, other.small, t)!,
      medium: BorderRadius.lerp(medium, other.medium, t)!,
      large: BorderRadius.lerp(large, other.large, t)!,
      xl: BorderRadius.lerp(xl, other.xl, t)!,
      xxl: BorderRadius.lerp(xxl, other.xxl, t)!,
      pill: BorderRadius.lerp(pill, other.pill, t)!,
    );
  }
}
