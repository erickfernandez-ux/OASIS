import 'package:flutter/material.dart';
import 'dart:ui';

/// Centralized size tokens for reusable UI surfaces.
@immutable
class AppSizes extends ThemeExtension<AppSizes> {
  final double buttonHeight;
  final double iconSm;
  final double iconMd;
  final double iconLg;
  final double cardMinHeight;
  final double dialogMaxWidth;

  const AppSizes({
    required this.buttonHeight,
    required this.iconSm,
    required this.iconMd,
    required this.iconLg,
    required this.cardMinHeight,
    required this.dialogMaxWidth,
  });

  factory AppSizes.defaultSizes() {
    return const AppSizes(
      buttonHeight: 48,
      iconSm: 16,
      iconMd: 20,
      iconLg: 24,
      cardMinHeight: 96,
      dialogMaxWidth: 360,
    );
  }

  @override
  AppSizes copyWith({
    double? buttonHeight,
    double? iconSm,
    double? iconMd,
    double? iconLg,
    double? cardMinHeight,
    double? dialogMaxWidth,
  }) {
    return AppSizes(
      buttonHeight: buttonHeight ?? this.buttonHeight,
      iconSm: iconSm ?? this.iconSm,
      iconMd: iconMd ?? this.iconMd,
      iconLg: iconLg ?? this.iconLg,
      cardMinHeight: cardMinHeight ?? this.cardMinHeight,
      dialogMaxWidth: dialogMaxWidth ?? this.dialogMaxWidth,
    );
  }

  @override
  AppSizes lerp(ThemeExtension<AppSizes>? other, double t) {
    if (other is! AppSizes) return this;
    return AppSizes(
      buttonHeight: lerpDouble(buttonHeight, other.buttonHeight, t)!,
      iconSm: lerpDouble(iconSm, other.iconSm, t)!,
      iconMd: lerpDouble(iconMd, other.iconMd, t)!,
      iconLg: lerpDouble(iconLg, other.iconLg, t)!,
      cardMinHeight: lerpDouble(cardMinHeight, other.cardMinHeight, t)!,
      dialogMaxWidth: lerpDouble(dialogMaxWidth, other.dialogMaxWidth, t)!,
    );
  }
}
