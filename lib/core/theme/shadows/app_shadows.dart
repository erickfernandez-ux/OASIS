import 'package:flutter/material.dart';

/// Reusable shadow tokens for the OASIS design system.
/// Keeps elevation subtle and consistent across the app.
@immutable
class AppShadows extends ThemeExtension<AppShadows> {
  final BoxShadow subtle;
  final BoxShadow medium;
  final BoxShadow strong;

  const AppShadows({
    required this.subtle,
    required this.medium,
    required this.strong,
  });

  factory AppShadows.defaultShadows() {
    return const AppShadows(
      subtle: BoxShadow(
        color: Color(0x1A1F2937),
        blurRadius: 8,
        offset: Offset(0, 2),
      ),
      medium: BoxShadow(
        color: Color(0x331F2937),
        blurRadius: 16,
        offset: Offset(0, 6),
      ),
      strong: BoxShadow(
        color: Color(0x4D1F2937),
        blurRadius: 24,
        offset: Offset(0, 12),
      ),
    );
  }

  @override
  AppShadows copyWith({BoxShadow? subtle, BoxShadow? medium, BoxShadow? strong}) {
    return AppShadows(
      subtle: subtle ?? this.subtle,
      medium: medium ?? this.medium,
      strong: strong ?? this.strong,
    );
  }

  @override
  AppShadows lerp(ThemeExtension<AppShadows>? other, double t) {
    if (other is! AppShadows) return this;
    return AppShadows(
      subtle: BoxShadow.lerp(subtle, other.subtle, t)!,
      medium: BoxShadow.lerp(medium, other.medium, t)!,
      strong: BoxShadow.lerp(strong, other.strong, t)!,
    );
  }
}
