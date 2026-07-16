import 'package:flutter/material.dart';

import '../spacing/oasis_spacing.dart';

class OasisEmptyState extends StatelessWidget {
  const OasisEmptyState({
    required this.icon,
    required this.title,
    required this.description,
    this.action,
    super.key,
  });

  final IconData icon;
  final String title;
  final String description;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(OasisSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 42, color: const Color(0x88000000)),
            const SizedBox(height: OasisSpacing.sm),
            Text(title, style: textTheme.titleMedium, textAlign: TextAlign.center),
            const SizedBox(height: OasisSpacing.xs),
            Text(description, style: textTheme.bodyMedium, textAlign: TextAlign.center),
            if (action != null) ...[
              const SizedBox(height: OasisSpacing.md),
              action!,
            ],
          ],
        ),
      ),
    );
  }
}
