import 'package:flutter/material.dart';

import '../widgets/oasis_interactive.dart';

class OasisButton extends StatelessWidget {
  const OasisButton({
    required this.label,
    this.leading,
    this.onPressed,
    this.backgroundColor,
    this.foregroundColor,
    super.key,
  });

  final String label;
  final IconData? leading;
  final VoidCallback? onPressed;
  final Color? backgroundColor;
  final Color? foregroundColor;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final bg = backgroundColor ?? scheme.primary.withValues(alpha: 0.1);
    final fg = foregroundColor ?? scheme.onSurface;

    return OasisInteractive(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(14),
      child: _BreathingButtonSurface(
        enabled: onPressed != null,
        backgroundColor: bg,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (leading != null) ...[
                Icon(leading, size: 18, color: fg),
                const SizedBox(width: 8),
              ],
              Flexible(
                child: Text(
                  label,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: fg, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BreathingButtonSurface extends StatefulWidget {
  const _BreathingButtonSurface({
    required this.child,
    required this.backgroundColor,
    required this.enabled,
  });

  final Widget child;
  final Color backgroundColor;
  final bool enabled;

  @override
  State<_BreathingButtonSurface> createState() =>
      _BreathingButtonSurfaceState();
}

class _BreathingButtonSurfaceState extends State<_BreathingButtonSurface>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1700),
    );
    if (widget.enabled) {
      _controller.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(covariant _BreathingButtonSurface oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.enabled == oldWidget.enabled) return;
    if (widget.enabled) {
      _controller.repeat(reverse: true);
    } else {
      _controller.stop();
      _controller.value = 0;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      child: widget.child,
      builder: (context, child) {
        final breath = widget.enabled ? _controller.value : 0.0;
        final alpha = 0.12 + (0.06 * breath);
        return Container(
          decoration: BoxDecoration(
            color: widget.backgroundColor,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: widget.backgroundColor.withValues(alpha: alpha),
                blurRadius: 12 + (6 * breath),
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: child,
        );
      },
    );
  }
}
