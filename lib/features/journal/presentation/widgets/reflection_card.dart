import 'package:flutter/material.dart';

import '../../../../core/design/design_system.dart';

class ReflectionCard extends StatelessWidget {
  const ReflectionCard({
    required this.title,
    required this.controller,
    required this.hint,
    this.minLines = 3,
    super.key,
  });

  final String title;
  final TextEditingController controller;
  final String hint;
  final int minLines;

  @override
  Widget build(BuildContext context) {
    final typography = Theme.of(context).textTheme;

    return OasisCard(
      padding: const EdgeInsets.all(OasisSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: typography.titleMedium),
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
