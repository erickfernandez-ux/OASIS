import 'package:flutter/material.dart';

import '../canvas/canvas_theme.dart';
import '../../../features/settings/domain/enums/canvas_motion_preference.dart';
import '../../../features/settings/domain/enums/canvas_style_preference.dart';
import '../widgets/living_paper_background.dart';

class OasisWatercolorBackground extends StatelessWidget {
  const OasisWatercolorBackground({
    required this.child,
    required this.accent,
    this.fadeIn = true,
    this.environment,
    this.backgroundAssetOverride,
    this.motionOverride,
    super.key,
  });

  final Widget child;
  final Color accent;
  final bool fadeIn;
  final CanvasStylePreference? environment;
  final String? backgroundAssetOverride;
  final CanvasMotionPreference? motionOverride;

  @override
  Widget build(BuildContext context) {
    final themeCanvas = Theme.of(context).extension<CanvasTheme>();
    final resolvedEnvironment =
        environment ?? themeCanvas?.style ?? CanvasStylePreference.forest;

    return LivingPaperBackground(
      environment: resolvedEnvironment,
      accent: accent,
      assetOverride: backgroundAssetOverride,
      child: child,
    );
  }
}
