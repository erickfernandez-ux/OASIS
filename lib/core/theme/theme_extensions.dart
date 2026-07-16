import 'package:flutter/material.dart';
import 'animations/app_animations.dart';
import 'colors/app_colors.dart';
import 'elevation/app_elevation.dart';
import 'radius/app_radius.dart';
import 'shadows/app_shadows.dart';
import 'sizes/app_sizes.dart';
import 'spacing/app_spacing.dart';
import 'typography/app_typography.dart';
import '../design/canvas/canvas_theme.dart';

/// Helpers to access the Design System from BuildContext.
extension BuildContextTheme on BuildContext {
  AppColors get appColors => Theme.of(this).extension<AppColors>()!;
  AppTypography get appTypography => Theme.of(this).extension<AppTypography>()!;
  AppSpacing get appSpacing => Theme.of(this).extension<AppSpacing>()!;
  AppRadius get appRadius => Theme.of(this).extension<AppRadius>()!;
  AppElevation get appElevation => Theme.of(this).extension<AppElevation>()!;
  AppShadows get appShadows => Theme.of(this).extension<AppShadows>()!;
  AppSizes get appSizes => Theme.of(this).extension<AppSizes>()!;
  AppAnimations get appAnimations => Theme.of(this).extension<AppAnimations>()!;
  CanvasTheme get appCanvas => Theme.of(this).extension<CanvasTheme>()!;
}
