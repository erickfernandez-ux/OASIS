import 'package:flutter/material.dart';
import '../../core/theme/theme_extensions.dart';

/// Reusable icon-only button for compact actions.
class AppIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  final bool isDisabled;
  final double? size;
  final Color? foregroundColor;

  const AppIconButton({
    required this.icon,
    this.onPressed,
    this.isDisabled = false,
    this.size,
    this.foregroundColor,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final radius = context.appRadius;

    return IconButton(
      onPressed: isDisabled ? null : onPressed,
      style: IconButton.styleFrom(
        backgroundColor: colors.component.buttonSecondaryBackground,
        foregroundColor: foregroundColor ?? colors.semantic.primary,
        shape: RoundedRectangleBorder(borderRadius: radius.medium),
        padding: const EdgeInsets.all(10),
      ),
      icon: Icon(icon, size: size ?? 20),
    );
  }
}
