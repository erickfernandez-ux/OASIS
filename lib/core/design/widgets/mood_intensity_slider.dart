import 'package:flutter/material.dart';

import '../spacing/oasis_spacing.dart';
import 'oasis_inputs.dart';

class MoodIntensitySlider extends StatelessWidget {
  const MoodIntensitySlider({
    required this.label,
    required this.value,
    required this.onChanged,
    this.minLabel = 'Bajo',
    this.maxLabel = 'Alto',
    this.max = 10,
    super.key,
  });

  final String label;
  final double value;
  final ValueChanged<double> onChanged;
  final String minLabel;
  final String maxLabel;
  final int max;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(child: Text(label, style: text.titleSmall)),
            Text(value.round().toString(), style: text.labelMedium),
          ],
        ),
        OasisSlider(
          value: value,
          min: 0,
          max: max.toDouble(),
          onChanged: onChanged,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(minLabel, style: text.bodySmall),
            Text(maxLabel, style: text.bodySmall),
          ],
        ),
        const SizedBox(height: OasisSpacing.sm),
      ],
    );
  }
}
