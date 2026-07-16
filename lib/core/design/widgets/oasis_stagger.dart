import 'package:flutter/material.dart';

import '../animations/motion_spec.dart';
import '../animations/oasis_animations.dart';

class OasisStagger extends StatefulWidget {
  const OasisStagger({required this.index, required this.child, super.key});

  final int index;
  final Widget child;

  @override
  State<OasisStagger> createState() => _OasisStaggerState();
}

class _OasisStaggerState extends State<OasisStagger> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: MotionSpec.pageReverse);
    _animation = CurvedAnimation(parent: _controller, curve: MotionSpec.easeOut);
    Future.delayed(
      Duration(milliseconds: OasisAnimations.staggerStep.inMilliseconds * widget.index),
      () {
        if (mounted) {
          _controller.forward();
        }
      },
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        final value = _animation.value;
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, (1 - value) * 10),
            child: Transform.scale(
              scale: MotionSpec.beginScale + ((1 - MotionSpec.beginScale) * value),
              child: child,
            ),
          ),
        );
      },
      child: widget.child,
    );
  }
}
