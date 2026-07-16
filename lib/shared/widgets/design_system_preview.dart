import 'package:flutter/material.dart';
import '../../core/theme/theme_extensions.dart';
import '../../core/design/design_system.dart' as od;
import 'app_card.dart';
import 'app_text_field.dart';
import 'icon_button.dart';
import 'primary_button.dart';
import 'secondary_button.dart';
import 'text_button.dart';
import 'floating_button.dart';

/// Preview scaffold for the design system.
/// Kept as a reusable presentation helper, not a production screen.
class DesignSystemPreview extends StatelessWidget {
  const DesignSystemPreview({super.key});

  @override
  Widget build(BuildContext context) {
    final spacing = context.appSpacing;

    return SingleChildScrollView(
      padding: spacing.paddingLarge,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Buttons', style: context.appTypography.title),
          SizedBox(height: spacing.sm),
          Row(children: [
            const PrimaryButton(text: 'Primary'),
            SizedBox(width: spacing.sm),
            const SecondaryButton(text: 'Secondary'),
          ]),
          SizedBox(height: spacing.sm),
          const AppTextButton(text: 'Text action'),
          SizedBox(height: spacing.sm),
          const AppIconButton(icon: Icons.add),
          SizedBox(height: spacing.sm),
          const AppFloatingButton(icon: Icons.add),
          SizedBox(height: spacing.lg),
          Text('Cards and fields', style: context.appTypography.title),
          SizedBox(height: spacing.sm),
          const AppCard(child: Text('Card content')),
          SizedBox(height: spacing.sm),
          const AppTextField(label: 'Email', hint: 'name@example.com'),
          SizedBox(height: spacing.lg),
          Text('Chips', style: context.appTypography.title),
          SizedBox(height: spacing.sm),
          const Wrap(spacing: 8, runSpacing: 8, children: [
            od.OasisStatusChip(label: 'Ready', color: Colors.green),
            od.OasisTagChip(label: 'Home'),
            od.OasisFilterChip(label: 'All', selected: true),
          ]),
        ],
      ),
    );
  }
}
