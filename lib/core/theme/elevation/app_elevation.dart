import 'package:flutter/material.dart';

/// Design system shadows.
/// Japandi uses soft, diffuse shadows — never harsh.
@immutable
class AppElevation extends ThemeExtension<AppElevation> {
  final BoxShadow card;
  final BoxShadow elevated;
  final BoxShadow modal;
  final BoxShadow dropdown;

  const AppElevation({
    required this.card,
    required this.elevated,
    required this.modal,
    required this.dropdown,
  });

  factory AppElevation.light() {
    return AppElevation(
      card: BoxShadow(
        color: const Color(0xFF000000).withValues(alpha: 0.04),
        blurRadius: 12,
        offset: const Offset(0, 4),
      ),
      elevated: BoxShadow(
        color: const Color(0xFF000000).withValues(alpha: 0.06),
        blurRadius: 20,
        offset: const Offset(0, 8),
      ),
      modal: BoxShadow(
        color: const Color(0xFF000000).withValues(alpha: 0.12),
        blurRadius: 32,
        offset: const Offset(0, 16),
      ),
      dropdown: BoxShadow(
        color: const Color(0xFF000000).withValues(alpha: 0.08),
        blurRadius: 16,
        offset: const Offset(0, 6),
      ),
    );
  }

  factory AppElevation.dark() {
    return AppElevation(
      card: BoxShadow(
        color: const Color(0xFF000000).withValues(alpha: 0.24),
        blurRadius: 12,
        offset: const Offset(0, 4),
      ),
      elevated: BoxShadow(
        color: const Color(0xFF000000).withValues(alpha: 0.32),
        blurRadius: 20,
        offset: const Offset(0, 8),
      ),
      modal: BoxShadow(
        color: const Color(0xFF000000).withValues(alpha: 0.48),
        blurRadius: 32,
        offset: const Offset(0, 16),
      ),
      dropdown: BoxShadow(
        color: const Color(0xFF000000).withValues(alpha: 0.36),
        blurRadius: 16,
        offset: const Offset(0, 6),
      ),
    );
  }

  @override
  AppElevation copyWith({
    BoxShadow? card,
    BoxShadow? elevated,
    BoxShadow? modal,
    BoxShadow? dropdown,
  }) {
    return AppElevation(
      card: card ?? this.card,
      elevated: elevated ?? this.elevated,
      modal: modal ?? this.modal,
      dropdown: dropdown ?? this.dropdown,
    );
  }

  @override
  AppElevation lerp(ThemeExtension<AppElevation>? other, double t) {
    if (other is! AppElevation) return this;
    return AppElevation(
      card: BoxShadow.lerp(card, other.card, t)!,
      elevated: BoxShadow.lerp(elevated, other.elevated, t)!,
      modal: BoxShadow.lerp(modal, other.modal, t)!,
      dropdown: BoxShadow.lerp(dropdown, other.dropdown, t)!,
    );
  }
}
