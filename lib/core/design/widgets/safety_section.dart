import 'package:flutter/material.dart';

import '../spacing/oasis_spacing.dart';
import 'oasis_divider.dart';
import 'oasis_surface.dart';

class SafetySection extends StatelessWidget {
  const SafetySection({
    required this.title,
    required this.child,
    this.subtitle,
    this.level = 2,
    super.key,
  });

  final String title;
  final String? subtitle;
  final Widget child;
  final int level;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;

    return OasisSurface(
      level: level,
      padding: const EdgeInsets.all(OasisSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: text.titleLarge),
          if (subtitle != null) ...[
            const SizedBox(height: OasisSpacing.xs),
            Text(subtitle!, style: text.bodyMedium),
          ],
          const SizedBox(height: OasisSpacing.sm),
          const OasisDivider(),
          const SizedBox(height: OasisSpacing.md),
          child,
        ],
      ),
    );
  }
}
