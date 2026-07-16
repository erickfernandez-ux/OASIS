import 'package:flutter/material.dart';

class OasisDivider extends StatelessWidget {
  const OasisDivider({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Divider(
      color: scheme.outlineVariant.withValues(alpha: 0.4),
      thickness: 0.8,
      height: 1,
    );
  }
}
