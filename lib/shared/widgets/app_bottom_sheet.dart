import 'package:flutter/material.dart';
import '../../core/theme/theme_extensions.dart';

/// Reusable bottom sheet wrapper.
class AppBottomSheet extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;

  const AppBottomSheet({
    required this.child,
    this.padding,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final radius = context.appRadius;

    return Padding(
      padding: padding ?? EdgeInsets.all(context.appSpacing.md),
      child: Container(
        decoration: BoxDecoration(
          color: colors.semantic.surface,
          borderRadius: BorderRadius.vertical(top: radius.large.topLeft),
        ),
        child: child,
      ),
    );
  }
}
