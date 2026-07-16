import 'package:flutter/material.dart';

import 'oasis_surface.dart';

class OasisGlassCard extends StatelessWidget {
  const OasisGlassCard({
    required this.child,
    this.padding = const EdgeInsets.all(16),
    super.key,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return OasisSurface(
      level: 2,
      glass: true,
      padding: padding,
      child: child,
    );
  }
}
