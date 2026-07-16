import 'package:flutter/material.dart';

import '../spacing/oasis_spacing.dart';
import 'oasis_primary_card.dart';

class HopeCard extends StatelessWidget {
  const HopeCard({
    required this.title,
    required this.child,
    super.key,
  });

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;

    return OasisPrimaryCard(
      padding: const EdgeInsets.all(OasisSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: text.titleLarge),
          const SizedBox(height: OasisSpacing.md),
          child,
        ],
      ),
    );
  }
}
