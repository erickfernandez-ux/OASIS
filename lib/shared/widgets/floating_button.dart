import 'package:flutter/material.dart';
import '../../core/theme/theme_extensions.dart';

/// Reusable floating action button for primary actions.
class AppFloatingButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  final String? label;

  const AppFloatingButton({
    required this.icon,
    this.onPressed,
    this.label,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final radius = context.appRadius;

    if (label != null) {
      return FloatingActionButton.extended(
        onPressed: onPressed,
        backgroundColor: colors.component.fabBackground,
        foregroundColor: colors.component.fabForeground,
        shape: RoundedRectangleBorder(borderRadius: radius.xl),
        icon: Icon(icon),
        label: Text(label!),
      );
    }

    return FloatingActionButton(
      onPressed: onPressed,
      backgroundColor: colors.component.fabBackground,
      foregroundColor: colors.component.fabForeground,
      shape: RoundedRectangleBorder(borderRadius: radius.xl),
      child: Icon(icon),
    );
  }
}
