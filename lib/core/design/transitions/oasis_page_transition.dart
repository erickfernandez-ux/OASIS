import 'package:flutter/material.dart';

import '../animations/motion_spec.dart';

class OasisPageTransition {
  const OasisPageTransition._();

  static Widget build(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    final curved = CurvedAnimation(parent: animation, curve: MotionSpec.easeInOut);
    return FadeTransition(
      opacity: curved,
      child: SlideTransition(
        position: Tween<Offset>(begin: const Offset(0.0, 0.012), end: Offset.zero).animate(curved),
        child: ScaleTransition(
          scale: Tween<double>(begin: MotionSpec.pageScale, end: 1).animate(curved),
          child: child,
        ),
      ),
    );
  }
}
