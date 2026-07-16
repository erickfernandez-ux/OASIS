import 'package:flutter/material.dart';

import '../animations/motion_spec.dart';
import '../radius/oasis_radius.dart';
import '../spacing/oasis_spacing.dart';

class OasisChip extends StatelessWidget {
  const OasisChip({
    super.key,
    required this.label,
    this.icon,
    this.onTap,
    this.selected = false,
    this.backgroundColor,
    this.foregroundColor,
  });

  final String label;
  final IconData? icon;
  final VoidCallback? onTap;
  final bool selected;
  final Color? backgroundColor;
  final Color? foregroundColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final fg = foregroundColor ?? (selected ? scheme.primary : scheme.onSurfaceVariant);
    final bg = backgroundColor ?? (selected ? scheme.primary.withValues(alpha: 0.12) : scheme.surfaceContainerHighest.withValues(alpha: 0.55));

    return GestureDetector(
      onTap: onTap,
      child: AnimatedScale(
        duration: MotionSpec.micro,
        curve: MotionSpec.easeOut,
        scale: onTap == null ? 1 : 1,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: OasisSpacing.md, vertical: OasisSpacing.xs),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: OasisRadius.pill,
            border: Border.all(color: selected ? scheme.primary : scheme.outlineVariant),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(icon, size: 16, color: fg),
                const SizedBox(width: 6),
              ],
              Text(label, style: TextStyle(color: fg)),
            ],
          ),
        ),
      ),
    );
  }
}

class OasisFilterChip extends OasisChip {
  const OasisFilterChip({super.key, required super.label, super.icon, super.onTap, super.selected = false});
}

class OasisTagChip extends OasisChip {
  const OasisTagChip({super.key, required super.label, super.onTap, super.selected = false}) : super(icon: null);
}

class OasisStatusChip extends StatelessWidget {
  const OasisStatusChip({
    super.key,
    required this.label,
    required this.color,
  });

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: OasisSpacing.md, vertical: OasisSpacing.xs),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: OasisRadius.pill,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(width: 6, height: 6, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
          const SizedBox(width: 6),
          Text(label, style: TextStyle(color: color)),
        ],
      ),
    );
  }
}
