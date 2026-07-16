import 'package:flutter/material.dart';

import '../../theme/icons/app_icons.dart';
import 'oasis_interactive.dart';

class EmergencyButton extends StatelessWidget {
  const EmergencyButton({
    required this.onTap,
    this.isActive = false,
    this.tooltip = 'Abrir Safety Plan',
    super.key,
  });

  final VoidCallback onTap;
  final bool isActive;
  final String tooltip;

  @override
  Widget build(BuildContext context) {
    final bg = isActive ? const Color(0xFF6B2F2F) : const Color(0xFF3F4A50);

    return OasisInteractive(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: Tooltip(
        message: tooltip,
        child: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: bg,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white.withValues(alpha: 0.22)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.12),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: const Icon(
            AppIcons.warning,
            color: Colors.white,
            size: 20,
          ),
        ),
      ),
    );
  }
}
