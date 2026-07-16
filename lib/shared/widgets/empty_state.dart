import 'package:flutter/material.dart';
import '../../core/theme/icons/app_icons.dart';
import '../../core/theme/theme_extensions.dart';

/// Reusable empty state widget.
/// Displays icon, title, description, and optional action.
class EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? description;
  final Widget? action;

  const EmptyState({
    this.icon = AppIcons.empty,
    required this.title,
    this.description,
    this.action,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final typography = context.appTypography;
    final spacing = context.appSpacing;

    return Center(
      child: Padding(
        padding: spacing.paddingLarge,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: AppIconSize.xl.value,
              color: colors.semantic.textDisabled,
            ),
            SizedBox(height: spacing.lg),
            Text(
              title,
              style: typography.title.copyWith(color: colors.semantic.textPrimary),
              textAlign: TextAlign.center,
            ),
            if (description != null) ...[
              SizedBox(height: spacing.sm),
              Text(
                description!,
                style: typography.body.copyWith(color: colors.semantic.textSecondary),
                textAlign: TextAlign.center,
              ),
            ],
            if (action != null) ...[
              SizedBox(height: spacing.lg),
              action!,
            ],
          ],
        ),
      ),
    );
  }
}
