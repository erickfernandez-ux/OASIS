import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../animations/motion_spec.dart';

class OasisInteractive extends StatefulWidget {
  const OasisInteractive({
    required this.child,
    this.onTap,
    this.onLongPress,
    this.borderRadius,
    super.key,
  });

  final Widget child;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final BorderRadius? borderRadius;

  @override
  State<OasisInteractive> createState() => _OasisInteractiveState();
}

class _OasisInteractiveState extends State<OasisInteractive> {
  bool _hovered = false;
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final scale = _pressed
        ? MotionSpec.pressedScale
        : (_hovered ? MotionSpec.hoverScale : 1.0);
    final liftY = _hovered ? -MotionSpec.hoverLiftPx : 0.0;

    return MouseRegion(
      onEnter: (_) {
        if (kIsWeb ||
            defaultTargetPlatform == TargetPlatform.macOS ||
            defaultTargetPlatform == TargetPlatform.windows ||
            defaultTargetPlatform == TargetPlatform.linux) {
          setState(() => _hovered = true);
        }
      },
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTapDown: (_) => setState(() => _pressed = true),
        onTapUp: (_) => setState(() => _pressed = false),
        onTapCancel: () => setState(() => _pressed = false),
        onTap: widget.onTap,
        onLongPress: widget.onLongPress,
        child: AnimatedContainer(
          duration: MotionSpec.hover,
          curve: MotionSpec.easeOut,
          transform: Matrix4.translationValues(0, liftY, 0),
          child: AnimatedScale(
            duration: MotionSpec.micro,
            curve: MotionSpec.easeOut,
            scale: scale,
            child: ClipRRect(
              borderRadius: widget.borderRadius ?? BorderRadius.zero,
              child: widget.child,
            ),
          ),
        ),
      ),
    );
  }
}
