import 'dart:ui';

import 'package:flutter/material.dart';

import '../canvas/canvas_theme.dart';
import '../radius/oasis_radius.dart';
import '../shadows/shadow_spec.dart';
import '../spacing/oasis_spacing.dart';

class OasisSurface extends StatelessWidget {
  const OasisSurface({
    required this.child,
    this.padding = OasisSpacing.card,
    this.margin,
    this.level = 2,
    this.glass = false,
    super.key,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry? margin;
  final int level;
  final bool glass;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final canvas = theme.extension<CanvasTheme>();
    final ambientShadow = (canvas?.primaryTone ?? scheme.primary)
        .withValues(alpha: theme.brightness == Brightness.dark ? 0.38 : 0.20);
    final shadows = switch (level) {
      1 => ShadowSpec.level1(ambientShadow),
      2 => ShadowSpec.level2(ambientShadow),
      3 => ShadowSpec.level3(ambientShadow),
      _ => ShadowSpec.level4(ambientShadow),
    };

    final paperColor = theme.brightness == Brightness.dark
        ? const Color(0xFF2B2524).withValues(alpha: 0.82)
        : const Color(0xFFFCFBF8).withValues(alpha: 0.82);

    final base = Container(
      margin: margin,
      decoration: BoxDecoration(
        color: paperColor,
        borderRadius: OasisRadius.card,
        border:
            Border.all(color: Colors.white.withValues(alpha: 0.46), width: 0.9),
        boxShadow: shadows,
      ),
      child: Material(
        type: MaterialType.transparency,
        child: Padding(
          padding: padding,
          child: child,
        ),
      ),
    );

    if (!glass) return base;

    return ClipRRect(
      borderRadius: OasisRadius.card,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: base,
      ),
    );
  }
}
