import 'package:flutter/material.dart';
import '../../core/theme/icons/app_icons.dart';
import '../../core/theme/theme_extensions.dart';

/// Primary action button.
/// Minimum height 48dp for touch accessibility.
class PrimaryButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isDisabled;
  final IconData? leadingIcon;
  final IconData? trailingIcon;

  const PrimaryButton({
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.isDisabled = false,
    this.leadingIcon,
    this.trailingIcon,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final radius = context.appRadius;
    final typography = context.appTypography;
    final spacing = context.appSpacing;
    final sizes = context.appSizes;

    final bool isInactive = isLoading || isDisabled;

    return Semantics(
      button: true,
      label: text,
      child: SizedBox(
        height: sizes.buttonHeight,
        child: ElevatedButton(
          onPressed: isInactive ? null : onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: colors.component.buttonPrimaryBackground,
            foregroundColor: colors.component.buttonPrimaryForeground,
            disabledBackgroundColor: colors.semantic.textDisabled.withValues(alpha: 0.2),
            disabledForegroundColor: colors.semantic.textDisabled,
            elevation: 0,
            padding: EdgeInsets.symmetric(horizontal: spacing.md),
            shape: RoundedRectangleBorder(borderRadius: radius.medium),
          ),
          child: isLoading
              ? SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: colors.component.buttonPrimaryForeground,
                  ),
                )
              : Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (leadingIcon != null) ...[
                      Icon(leadingIcon, size: AppIconSize.md.value),
                      SizedBox(width: spacing.sm),
                    ],
                    Flexible(
                      child: Text(
                        text,
                        style: typography.label.copyWith(
                          color: colors.component.buttonPrimaryForeground,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (trailingIcon != null) ...[
                      SizedBox(width: spacing.sm),
                      Icon(trailingIcon, size: AppIconSize.md.value),
                    ],
                  ],
                ),
        ),
      ),
    );
  }
}
