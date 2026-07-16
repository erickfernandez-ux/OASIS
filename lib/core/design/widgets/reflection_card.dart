import 'package:flutter/material.dart';

import '../spacing/oasis_spacing.dart';
import 'oasis_inputs.dart';
import 'oasis_surface.dart';

class ReflectionCard extends StatelessWidget {
  const ReflectionCard({
    required this.title,
    required this.controller,
    required this.hint,
    this.minLines = 2,
    super.key,
  });

  final String title;
  final TextEditingController controller;
  final String hint;
  final int minLines;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;

    return OasisSurface(
      level: 2,
      padding: const EdgeInsets.all(OasisSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: text.titleMedium),
          const SizedBox(height: OasisSpacing.sm),
          OasisMultilineField(
            controller: controller,
            hint: hint,
            minLines: minLines,
          ),
        ],
      ),
    );
  }
}
