import 'package:flutter/material.dart';

import '../../core/design/design_system.dart' as od;

/// Reusable filter chip for selection-driven lists.
class FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback? onTap;

  const FilterChip({
    required this.label,
    this.isSelected = false,
    this.onTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return od.OasisFilterChip(
      label: label,
      selected: isSelected,
      onTap: onTap,
    );
  }
}
