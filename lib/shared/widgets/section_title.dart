import 'package:flutter/material.dart';
import '../../core/theme/theme_extensions.dart';

/// Section title with optional decorative divider.
/// Used to group content on screens.
class SectionTitle extends StatelessWidget {
  final String title;
  final String? subtitle;
  final bool showDivider;

  const SectionTitle({
    required this.title,
    this.subtitle,
    this.showDivider = true,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final typography = context.appTypography;
    final spacing = context.appSpacing;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (showDivider)
          Container(
            width: 24,
            height: 2,
            color: colors.semantic.accent,
            margin: EdgeInsets.only(bottom: spacing.sm),
          ),
        Text(
          title,
          style: typography.headline.copyWith(color: colors.semantic.textPrimary),
        ),
        if (subtitle != null) ...[
          SizedBox(height: spacing.xs),
          Text(
            subtitle!,
            style: typography.body.copyWith(color: colors.semantic.textSecondary),
          ),
        ],
        SizedBox(height: spacing.md),
      ],
    );
  }
}
