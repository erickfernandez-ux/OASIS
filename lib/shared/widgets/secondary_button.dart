import 'package:flutter/material.dart';
import '../../core/theme/icons/app_icons.dart';
import '../../core/theme/theme_extensions.dart';

/// Secondary outlined button.
/// Used for alternative or cancel actions.
class SecondaryButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isDisabled;
  final IconData? leadingIcon;

  const SecondaryButton({
    required this.text,
    this.onPressed,
    this.isDisabled = false,
    this.leadingIcon,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final radius = context.appRadius;
    final typography = context.appTypography;
    final spacing = context.appSpacing;
    final sizes = context.appSizes;

    return Semantics(
      button: true,
      label: text,
      child: SizedBox(
        height: sizes.buttonHeight,
        child: OutlinedButton(
          onPressed: isDisabled ? null : onPressed,
          style: OutlinedButton.styleFrom(
            foregroundColor: colors.component.buttonSecondaryForeground,
            side: BorderSide(
              color: isDisabled
                  ? colors.semantic.textDisabled
                  : colors.component.buttonSecondaryBorder,
            ),
            padding: EdgeInsets.symmetric(horizontal: spacing.md),
            shape: RoundedRectangleBorder(borderRadius: radius.medium),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (leadingIcon != null) ...[
                Icon(leadingIcon, size: AppIconSize.md.value),
                SizedBox(width: spacing.sm),
              ],
              Flexible(
                child: Text(
                  text,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                  style: typography.label.copyWith(
                    color: isDisabled
                        ? colors.semantic.textDisabled
                        : colors.component.buttonSecondaryForeground,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
