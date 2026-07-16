import 'package:flutter/material.dart';

/// Primitive Japandi palette.
/// Pure colors without semantic meaning.
/// The app must consume SemanticColors or ComponentColors, never these directly.
class PrimitiveColors {
  PrimitiveColors._();

  // Neutrals
  static const Color ink = Color(0xFF1A1A1A);
  static const Color charcoal = Color(0xFF242424);
  static const Color fog = Color(0xFF6B6B6B);
  static const Color mist = Color(0xFF9E9E9E);
  static const Color cloud = Color(0xFFE0E0E0);
  static const Color stone = Color(0xFFF5F5F0);
  static const Color paper = Color(0xFFFFFFFF);

  // Nature
  static const Color moss = Color(0xFF2C3E33);
  static const Color mossLight = Color(0xFF4A6352);
  static const Color sage = Color(0xFFA8B5A0);
  static const Color sand = Color(0xFFBCAEA4);
  static const Color sandDark = Color(0xFF9E8F82);

  // Watercolor
  static const Color clay = Color(0xFFC07756);
  static const Color clayLight = Color(0xFFD4956C);
  static const Color terracotta = Color(0xFF8B5E3C);

  // States
  static const Color forest = Color(0xFF2E7D32);
  static const Color forestLight = Color(0xFF81C784);
  static const Color amber = Color(0xFFF9A825);
  static const Color amberLight = Color(0xFFFFE082);
  static const Color rose = Color(0xFFB00020);
  static const Color roseLight = Color(0xFFCF6679);
  static const Color sky = Color(0xFF0288D1);
  static const Color skyLight = Color(0xFF81D4FA);
}
