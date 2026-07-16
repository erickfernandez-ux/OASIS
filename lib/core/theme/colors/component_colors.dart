import 'package:flutter/material.dart';
import 'primitive_colors.dart';

/// Component-specific colors.
/// Decouples widget appearance from semantic meaning.
@immutable
class ComponentColors extends ThemeExtension<ComponentColors> {
  final Color buttonPrimaryBackground;
  final Color buttonPrimaryForeground;
  final Color buttonSecondaryBackground;
  final Color buttonSecondaryForeground;
  final Color buttonSecondaryBorder;
  final Color cardBackground;
  final Color cardBorder;
  final Color inputBackground;
  final Color inputBorder;
  final Color inputBorderFocused;
  final Color fabBackground;
  final Color fabForeground;
  final Color chipBackground;
  final Color chipForeground;
  final Color chipBorder;
  final Color appBarBackground;
  final Color appBarForeground;
  final Color navBarBackground;
  final Color navBarSelected;
  final Color navBarUnselected;

  const ComponentColors({
    required this.buttonPrimaryBackground,
    required this.buttonPrimaryForeground,
    required this.buttonSecondaryBackground,
    required this.buttonSecondaryForeground,
    required this.buttonSecondaryBorder,
    required this.cardBackground,
    required this.cardBorder,
    required this.inputBackground,
    required this.inputBorder,
    required this.inputBorderFocused,
    required this.fabBackground,
    required this.fabForeground,
    required this.chipBackground,
    required this.chipForeground,
    required this.chipBorder,
    required this.appBarBackground,
    required this.appBarForeground,
    required this.navBarBackground,
    required this.navBarSelected,
    required this.navBarUnselected,
  });

  factory ComponentColors.light() {
    return const ComponentColors(
      buttonPrimaryBackground: PrimitiveColors.moss,
      buttonPrimaryForeground: PrimitiveColors.paper,
      buttonSecondaryBackground: PrimitiveColors.paper,
      buttonSecondaryForeground: PrimitiveColors.moss,
      buttonSecondaryBorder: PrimitiveColors.moss,
      cardBackground: PrimitiveColors.paper,
      cardBorder: PrimitiveColors.cloud,
      inputBackground: PrimitiveColors.paper,
      inputBorder: PrimitiveColors.cloud,
      inputBorderFocused: PrimitiveColors.moss,
      fabBackground: PrimitiveColors.clay,
      fabForeground: PrimitiveColors.paper,
      chipBackground: PrimitiveColors.stone,
      chipForeground: PrimitiveColors.ink,
      chipBorder: PrimitiveColors.cloud,
      appBarBackground: PrimitiveColors.stone,
      appBarForeground: PrimitiveColors.ink,
      navBarBackground: PrimitiveColors.paper,
      navBarSelected: PrimitiveColors.moss,
      navBarUnselected: PrimitiveColors.fog,
    );
  }

  factory ComponentColors.dark() {
    return const ComponentColors(
      buttonPrimaryBackground: PrimitiveColors.sage,
      buttonPrimaryForeground: PrimitiveColors.ink,
      buttonSecondaryBackground: PrimitiveColors.charcoal,
      buttonSecondaryForeground: PrimitiveColors.sage,
      buttonSecondaryBorder: PrimitiveColors.sage,
      cardBackground: PrimitiveColors.charcoal,
      cardBorder: PrimitiveColors.fog,
      inputBackground: PrimitiveColors.charcoal,
      inputBorder: PrimitiveColors.fog,
      inputBorderFocused: PrimitiveColors.sage,
      fabBackground: PrimitiveColors.clayLight,
      fabForeground: PrimitiveColors.ink,
      chipBackground: PrimitiveColors.charcoal,
      chipForeground: PrimitiveColors.stone,
      chipBorder: PrimitiveColors.fog,
      appBarBackground: PrimitiveColors.ink,
      appBarForeground: PrimitiveColors.stone,
      navBarBackground: PrimitiveColors.charcoal,
      navBarSelected: PrimitiveColors.sage,
      navBarUnselected: PrimitiveColors.mist,
    );
  }

  @override
  ComponentColors copyWith({
    Color? buttonPrimaryBackground,
    Color? buttonPrimaryForeground,
    Color? buttonSecondaryBackground,
    Color? buttonSecondaryForeground,
    Color? buttonSecondaryBorder,
    Color? cardBackground,
    Color? cardBorder,
    Color? inputBackground,
    Color? inputBorder,
    Color? inputBorderFocused,
    Color? fabBackground,
    Color? fabForeground,
    Color? chipBackground,
    Color? chipForeground,
    Color? chipBorder,
    Color? appBarBackground,
    Color? appBarForeground,
    Color? navBarBackground,
    Color? navBarSelected,
    Color? navBarUnselected,
  }) {
    return ComponentColors(
      buttonPrimaryBackground: buttonPrimaryBackground ?? this.buttonPrimaryBackground,
      buttonPrimaryForeground: buttonPrimaryForeground ?? this.buttonPrimaryForeground,
      buttonSecondaryBackground: buttonSecondaryBackground ?? this.buttonSecondaryBackground,
      buttonSecondaryForeground: buttonSecondaryForeground ?? this.buttonSecondaryForeground,
      buttonSecondaryBorder: buttonSecondaryBorder ?? this.buttonSecondaryBorder,
      cardBackground: cardBackground ?? this.cardBackground,
      cardBorder: cardBorder ?? this.cardBorder,
      inputBackground: inputBackground ?? this.inputBackground,
      inputBorder: inputBorder ?? this.inputBorder,
      inputBorderFocused: inputBorderFocused ?? this.inputBorderFocused,
      fabBackground: fabBackground ?? this.fabBackground,
      fabForeground: fabForeground ?? this.fabForeground,
      chipBackground: chipBackground ?? this.chipBackground,
      chipForeground: chipForeground ?? this.chipForeground,
      chipBorder: chipBorder ?? this.chipBorder,
      appBarBackground: appBarBackground ?? this.appBarBackground,
      appBarForeground: appBarForeground ?? this.appBarForeground,
      navBarBackground: navBarBackground ?? this.navBarBackground,
      navBarSelected: navBarSelected ?? this.navBarSelected,
      navBarUnselected: navBarUnselected ?? this.navBarUnselected,
    );
  }

  @override
  ComponentColors lerp(ThemeExtension<ComponentColors>? other, double t) {
    if (other is! ComponentColors) return this;
    return ComponentColors(
      buttonPrimaryBackground: Color.lerp(buttonPrimaryBackground, other.buttonPrimaryBackground, t)!,
      buttonPrimaryForeground: Color.lerp(buttonPrimaryForeground, other.buttonPrimaryForeground, t)!,
      buttonSecondaryBackground: Color.lerp(buttonSecondaryBackground, other.buttonSecondaryBackground, t)!,
      buttonSecondaryForeground: Color.lerp(buttonSecondaryForeground, other.buttonSecondaryForeground, t)!,
      buttonSecondaryBorder: Color.lerp(buttonSecondaryBorder, other.buttonSecondaryBorder, t)!,
      cardBackground: Color.lerp(cardBackground, other.cardBackground, t)!,
      cardBorder: Color.lerp(cardBorder, other.cardBorder, t)!,
      inputBackground: Color.lerp(inputBackground, other.inputBackground, t)!,
      inputBorder: Color.lerp(inputBorder, other.inputBorder, t)!,
      inputBorderFocused: Color.lerp(inputBorderFocused, other.inputBorderFocused, t)!,
      fabBackground: Color.lerp(fabBackground, other.fabBackground, t)!,
      fabForeground: Color.lerp(fabForeground, other.fabForeground, t)!,
      chipBackground: Color.lerp(chipBackground, other.chipBackground, t)!,
      chipForeground: Color.lerp(chipForeground, other.chipForeground, t)!,
      chipBorder: Color.lerp(chipBorder, other.chipBorder, t)!,
      appBarBackground: Color.lerp(appBarBackground, other.appBarBackground, t)!,
      appBarForeground: Color.lerp(appBarForeground, other.appBarForeground, t)!,
      navBarBackground: Color.lerp(navBarBackground, other.navBarBackground, t)!,
      navBarSelected: Color.lerp(navBarSelected, other.navBarSelected, t)!,
      navBarUnselected: Color.lerp(navBarUnselected, other.navBarUnselected, t)!,
    );
  }
}
