import 'package:flutter/material.dart';

import 'oasis_interactive.dart';
import 'oasis_surface.dart';

class OasisPrimaryCard extends StatelessWidget {
  const OasisPrimaryCard({
    required this.child,
    this.padding = const EdgeInsets.all(24),
    super.key,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return OasisInteractive(
      borderRadius: BorderRadius.circular(24),
      child: OasisSurface(
        level: 3,
        padding: padding,
        child: child,
      ),
    );
  }
}
