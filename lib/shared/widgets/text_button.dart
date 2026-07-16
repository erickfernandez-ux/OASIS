import 'package:flutter/material.dart';
import '../../core/theme/theme_extensions.dart';

/// Reusable text button for low-emphasis actions.
class AppTextButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isDisabled;
  final IconData? leadingIcon;
  final IconData? trailingIcon;

  const AppTextButton({
    required this.text,
    this.onPressed,
    this.isDisabled = false,
    this.leadingIcon,
    this.trailingIcon,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final typography = context.appTypography;
    final spacing = context.appSpacing;

    return TextButton(
      onPressed: isDisabled ? null : onPressed,
      style: TextButton.styleFrom(
        foregroundColor: colors.semantic.primary,
        padding: EdgeInsets.symmetric(horizontal: spacing.sm),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (leadingIcon != null) ...[
            Icon(leadingIcon, size: 18),
            SizedBox(width: spacing.xs),
          ],
          Text(text, style: typography.label.copyWith(color: colors.semantic.primary)),
          if (trailingIcon != null) ...[
            SizedBox(width: spacing.xs),
            Icon(trailingIcon, size: 18),
          ],
        ],
      ),
    );
  }
}
