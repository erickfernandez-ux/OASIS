import 'package:flutter/material.dart';

import '../decorations/oasis_surfaces.dart';
import '../radius/oasis_radius.dart';
import '../shadows/oasis_shadows.dart';
import '../spacing/oasis_spacing.dart';
import 'oasis_interactive.dart';

class OasisCard extends StatelessWidget {
  const OasisCard({
    required this.child,
    this.onTap,
    this.onLongPress,
    this.padding,
    this.margin,
    super.key,
  });

  final Widget child;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;

  @override
  Widget build(BuildContext context) {
    final card = Container(
      margin: margin,
      padding: padding ?? OasisSpacing.card,
      decoration: BoxDecoration(
        color: OasisSurfaces.card,
        borderRadius: OasisRadius.card,
        border: Border.all(color: OasisSurfaces.border, width: 0.8),
        boxShadow: OasisShadows.card,
      ),
      child: child,
    );

    return OasisInteractive(
      onTap: onTap,
      onLongPress: onLongPress,
      borderRadius: OasisRadius.card,
      child: card,
    );
  }
}
