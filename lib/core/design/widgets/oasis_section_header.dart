import 'package:flutter/material.dart';

import '../spacing/oasis_spacing.dart';

class OasisSectionHeader extends StatelessWidget {
  const OasisSectionHeader({
    required this.title,
    this.subtitle,
    super.key,
  });

  final String title;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: text.titleLarge),
        if (subtitle != null) ...[
          const SizedBox(height: OasisSpacing.xs),
          Text(subtitle!, style: text.bodyMedium),
        ],
      ],
    );
  }
}
