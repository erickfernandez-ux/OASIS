import 'package:flutter/material.dart';

import 'canvas_theme.dart';

class CanvasAnimator extends StatefulWidget {
  const CanvasAnimator({
    required this.theme,
    required this.builder,
    super.key,
  });

  final CanvasTheme theme;
  final Widget Function(BuildContext context, double progress) builder;

  @override
  State<CanvasAnimator> createState() => _CanvasAnimatorState();
}

class _CanvasAnimatorState extends State<CanvasAnimator> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.theme.revealDuration);
    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _controller.forward();
      }
    });
  }

  @override
  void didUpdateWidget(covariant CanvasAnimator oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.theme.revealDuration != widget.theme.revealDuration) {
      _controller.duration = widget.theme.revealDuration;
      _controller.forward(from: 0);
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
      animation: _animation,
      builder: (context, child) {
        return widget.builder(context, _animation.value);
      },
    );
  }
}
