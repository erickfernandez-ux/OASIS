import 'package:flutter/material.dart';

import '../../theme/icons/app_icons.dart';
import '../spacing/oasis_spacing.dart';
import 'oasis_glass_card.dart';

class InsightCard extends StatelessWidget {
  const InsightCard({
    required this.message,
    this.icon = AppIcons.info,
    super.key,
  });

  final String message;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;

    return OasisGlassCard(
      padding: const EdgeInsets.all(OasisSpacing.md),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: scheme.primary),
          const SizedBox(width: OasisSpacing.sm),
          Expanded(
            child: Text(message, style: text.bodyMedium),
          ),
        ],
      ),
    );
  }
}
