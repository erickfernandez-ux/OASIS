import 'package:flutter/material.dart';
import '../../core/theme/icons/app_icons.dart';
import '../../core/theme/theme_extensions.dart';

/// Main Floating Action Button.
/// Variants: default, mini, extended.
class AppFAB extends StatelessWidget {
  final VoidCallback? onPressed;
  final IconData icon;
  final String? label;
  final bool mini;

  const AppFAB({
    this.onPressed,
    this.icon = AppIcons.add,
    this.label,
    this.mini = false,
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
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: radius.xl),
        icon: Icon(icon, size: AppIconSize.md.value),
        label: Text(label!),
      );
    }

    return FloatingActionButton(
      onPressed: onPressed,
      mini: mini,
      backgroundColor: colors.component.fabBackground,
      foregroundColor: colors.component.fabForeground,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: radius.xl),
      child: Icon(icon, size: AppIconSize.md.value),
    );
  }
}
