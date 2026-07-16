import 'package:flutter/material.dart';

import '../../core/design/design_system.dart';

/// Visual container with soft shadow and rounded corners.
/// Represents the elevated surface of the Japandi style.
class AppCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;
  final EdgeInsets? margin;
  final VoidCallback? onTap;
  final BorderRadius? borderRadius;
  final List<BoxShadow>? shadows;

  const AppCard({
    required this.child,
    this.padding,
    this.margin,
    this.onTap,
    this.borderRadius,
    this.shadows,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return OasisCard(
      padding: padding,
      margin: margin,
      onTap: onTap,
      child: child,
    );
  }
}
