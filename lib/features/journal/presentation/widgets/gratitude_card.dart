import 'package:flutter/material.dart';

import '../../../../core/design/design_system.dart';

class GratitudeCard extends StatelessWidget {
  const GratitudeCard({
    required this.controller,
    super.key,
  });

  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    final typography = Theme.of(context).textTheme;

    return OasisCard(
      padding: const EdgeInsets.all(OasisSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('¿Hay algo por lo que te sientas agradecido?', style: typography.titleMedium),
          const SizedBox(height: OasisSpacing.sm),
          OasisTextField(
            controller: controller,
            hint: 'Agradezco...',
          ),
        ],
      ),
    );
  }
}
