import 'package:flutter/material.dart';

@immutable
class OasisShadows {
  const OasisShadows._();

  static List<BoxShadow> get soft => [
        BoxShadow(
          color: const Color(0xFF111111).withValues(alpha: 0.035),
          blurRadius: 18,
          offset: const Offset(0, 8),
        ),
      ];

  static List<BoxShadow> get card => [
        BoxShadow(
          color: const Color(0xFF111111).withValues(alpha: 0.045),
          blurRadius: 24,
          offset: const Offset(0, 14),
        ),
      ];

  static List<BoxShadow> get hover => [
        BoxShadow(
          color: const Color(0xFF111111).withValues(alpha: 0.055),
          blurRadius: 28,
          offset: const Offset(0, 16),
        ),
      ];
}
