import 'package:flutter/material.dart';

import '../spacing/oasis_spacing.dart';
import 'oasis_chips.dart';

class EmotionCloud extends StatelessWidget {
  const EmotionCloud({
    required this.selected,
    required this.options,
    required this.onToggle,
    super.key,
  });

  final Set<String> selected;
  final List<String> options;
  final ValueChanged<String> onToggle;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: OasisSpacing.sm,
      runSpacing: OasisSpacing.sm,
      children: [
        for (final emotion in options)
          OasisChip(
            label: emotion,
            selected: selected.contains(emotion),
            onTap: () => onToggle(emotion),
          ),
      ],
    );
  }
}
