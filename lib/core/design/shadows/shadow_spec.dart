import 'package:flutter/material.dart';

@immutable
class ShadowSpec {
  const ShadowSpec._();

  static List<BoxShadow> level1(Color ambient) => [
        BoxShadow(
          color: ambient.withValues(alpha: 0.12),
          blurRadius: 12,
          offset: const Offset(0, 6),
        ),
      ];

  static List<BoxShadow> level2(Color ambient) => [
        BoxShadow(
          color: ambient.withValues(alpha: 0.16),
          blurRadius: 18,
          offset: const Offset(0, 10),
        ),
      ];

  static List<BoxShadow> level3(Color ambient) => [
        BoxShadow(
          color: ambient.withValues(alpha: 0.19),
          blurRadius: 24,
          offset: const Offset(0, 14),
        ),
      ];

  static List<BoxShadow> level4(Color ambient) => [
        BoxShadow(
          color: ambient.withValues(alpha: 0.22),
          blurRadius: 30,
          offset: const Offset(0, 16),
        ),
      ];
}
