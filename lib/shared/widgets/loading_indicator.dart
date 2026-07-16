import 'package:flutter/material.dart';
import '../../core/design/animations/motion_spec.dart';
import '../../core/theme/theme_extensions.dart';

/// Reusable loading indicator.
/// Supports circular and linear variants.
class LoadingIndicator extends StatelessWidget {
  final LoadingType type;
  final LoadingSize size;
  final Color? color;

  const LoadingIndicator({
    this.type = LoadingType.circular,
    this.size = LoadingSize.md,
    this.color,
    super.key,
  });

  double get _dimension {
    switch (size) {
      case LoadingSize.sm:
        return 16;
      case LoadingSize.md:
        return 24;
      case LoadingSize.lg:
        return 32;
    }
  }

  @override
  Widget build(BuildContext context) {
    final resolvedColor = color ?? context.appColors.semantic.primary;

    if (type == LoadingType.breathingPaper) {
      return _BreathingPaperLoader(color: resolvedColor, size: size);
    }

    if (type == LoadingType.linear) {
      return LinearProgressIndicator(
        color: resolvedColor,
        backgroundColor: resolvedColor.withValues(alpha: 0.12),
        minHeight: 2,
      );
    }

    return SizedBox(
      width: _dimension,
      height: _dimension,
      child: CircularProgressIndicator(
        strokeWidth: 2,
        color: resolvedColor,
      ),
    );
  }
}

enum LoadingType { circular, linear, breathingPaper }
enum LoadingSize { sm, md, lg }

class _BreathingPaperLoader extends StatefulWidget {
  const _BreathingPaperLoader({required this.color, required this.size});

  final Color color;
  final LoadingSize size;

  @override
  State<_BreathingPaperLoader> createState() => _BreathingPaperLoaderState();
}

class _BreathingPaperLoaderState extends State<_BreathingPaperLoader>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: MotionSpec.breathing,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final width = switch (widget.size) {
      LoadingSize.sm => 68.0,
      LoadingSize.md => 96.0,
      LoadingSize.lg => 128.0,
    };

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final t = _controller.value;
        final opacity = 0.35 + (0.45 * t);
        final lift = (1 - t) * 2;

        return Transform.translate(
          offset: Offset(0, lift),
          child: Opacity(
            opacity: opacity,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: width,
                  height: 12,
                  decoration: BoxDecoration(
                    color: widget.color.withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  width: width * 0.72,
                  height: 10,
                  decoration: BoxDecoration(
                    color: widget.color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
