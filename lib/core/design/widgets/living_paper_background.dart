import 'package:flutter/material.dart';

import '../animations/motion_spec.dart';
import '../../../features/settings/domain/enums/canvas_style_preference.dart';

class LivingPaperBackground extends StatefulWidget {
  const LivingPaperBackground({
    required this.environment,
    required this.accent,
    required this.child,
    this.assetOverride,
    this.transitionDuration = MotionSpec.backgroundCrossfade,
    super.key,
  });

  final CanvasStylePreference environment;
  final Color accent;
  final Widget child;
  final String? assetOverride;
  final Duration transitionDuration;

  @override
  State<LivingPaperBackground> createState() => _LivingPaperBackgroundState();
}

class _LivingPaperBackgroundState extends State<LivingPaperBackground> {
  AssetImage? _activeImage;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _resolveAndWarmImage();
  }

  @override
  void didUpdateWidget(covariant LivingPaperBackground oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.environment != widget.environment ||
        oldWidget.accent != widget.accent ||
        oldWidget.assetOverride != widget.assetOverride) {
      _resolveAndWarmImage();
    }
  }

  Future<void> _resolveAndWarmImage() async {
    final selectedAsset = widget.assetOverride ?? _assetFor(widget.environment);
    final image = AssetImage(selectedAsset);
    await precacheImage(image, context);

    if (!mounted) {
      return;
    }
    setState(() {
      _activeImage = image;
    });
  }

  static String _assetFor(CanvasStylePreference style) {
    return switch (style) {
      CanvasStylePreference.forest => 'assets/backgrounds/bosque.webp',
      CanvasStylePreference.mist => 'assets/backgrounds/bruma.webp',
      CanvasStylePreference.linen => 'assets/backgrounds/lino.webp',
      CanvasStylePreference.coast => 'assets/backgrounds/costa.webp',
      CanvasStylePreference.sereneNight =>
        'assets/backgrounds/noche serena.webp',
    };
  }

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final now = DateTime.now();
    final overlayTop = brightness == Brightness.dark
        ? const Color(0x661A1618)
        : const Color(0x22FFF8EE);
    final overlayBottom = brightness == Brightness.dark
        ? const Color(0x8020181D)
        : const Color(0x14FFFDF8);
    final ambient = brightness == Brightness.dark
        ? const Color(0x33E8CCB2)
        : const Color(0x26FFF5E7);
    final hourlyAmbient = _hourlyAmbient(now, brightness);

    final image = _activeImage;

    return Stack(
      fit: StackFit.expand,
      children: [
        Positioned.fill(
          child: ClipRect(
            child: AnimatedSwitcher(
              duration: widget.transitionDuration,
              switchInCurve: MotionSpec.easeInOut,
              switchOutCurve: MotionSpec.easeInOut,
              layoutBuilder: (currentChild, previousChildren) => Stack(
                fit: StackFit.expand,
                children: [
                  ...previousChildren,
                  if (currentChild != null) currentChild,
                ],
              ),
              child: image == null
                  ? const SizedBox.expand(
                      key: ValueKey<String>('paper-loading'),
                      child: ColoredBox(color: Color(0xFFF2ECE3)),
                    )
                  : SizedBox.expand(
                      key: ValueKey<String>(image.assetName),
                      child: Image(
                        image: image,
                        fit: BoxFit.cover,
                        filterQuality: FilterQuality.medium,
                        gaplessPlayback: true,
                      ),
                    ),
            ),
          ),
        ),
        Positioned.fill(
          child: IgnorePointer(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [overlayTop, Colors.transparent, overlayBottom],
                  stops: const [0.0, 0.38, 1.0],
                ),
              ),
            ),
          ),
        ),
        Positioned.fill(
          child: IgnorePointer(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: const Alignment(-0.8, -0.9),
                  radius: 1.1,
                  colors: [ambient, Colors.transparent],
                  stops: const [0.0, 1.0],
                ),
              ),
            ),
          ),
        ),
        Positioned.fill(
          child: IgnorePointer(
            child: AnimatedContainer(
              duration: MotionSpec.ambientShift,
              curve: MotionSpec.easeInOut,
              color: hourlyAmbient,
            ),
          ),
        ),
        Positioned.fill(child: widget.child),
      ],
    );
  }

  Color _hourlyAmbient(DateTime now, Brightness brightness) {
    final isMorning = now.hour >= 5 && now.hour < 12;
    final isAfternoon = now.hour >= 12 && now.hour < 19;

    if (isMorning) {
      return brightness == Brightness.dark
          ? const Color(0x228B5A2B)
          : const Color(0x14E8A35B);
    }

    if (isAfternoon) {
      return brightness == Brightness.dark
          ? const Color(0x10000000)
          : const Color(0x0AFFFFFF);
    }

    return brightness == Brightness.dark
        ? const Color(0x2A2E4E8D)
        : const Color(0x163B6FB5);
  }
}
