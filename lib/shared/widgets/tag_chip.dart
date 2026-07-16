import 'package:flutter/material.dart';

import '../../core/design/design_system.dart' as od;

/// Tag chip for categorization.
/// Supports selection and deletion.
class TagChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final bool isDeletable;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;

  const TagChip({
    required this.label,
    this.isSelected = false,
    this.isDeletable = false,
    this.onTap,
    this.onDelete,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return od.OasisTagChip(
      label: label,
      selected: isSelected,
      onTap: onTap,
    );
  }
}
