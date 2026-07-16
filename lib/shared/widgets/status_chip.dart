import 'package:flutter/material.dart';

import '../../core/design/design_system.dart' as od;
import '../../core/theme/theme_extensions.dart';

/// Status chip with color indicator.
/// Variants: success, warning, error, info.
class StatusChip extends StatelessWidget {
  final String label;
  final StatusType type;

  const StatusChip({
    required this.label,
    required this.type,
    super.key,
  });

  Color _resolveColor(BuildContext context) {
    final colors = context.appColors;
    switch (type) {
      case StatusType.success:
        return colors.semantic.success;
      case StatusType.warning:
        return colors.semantic.warning;
      case StatusType.error:
        return colors.semantic.error;
      case StatusType.info:
        return colors.semantic.info;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _resolveColor(context);
    return od.OasisStatusChip(
      label: label,
      color: color,
    );
  }
}

enum StatusType { success, warning, error, info }
