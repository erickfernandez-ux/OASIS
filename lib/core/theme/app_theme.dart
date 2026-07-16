import 'package:flutter/material.dart';
import 'animations/app_animations.dart';
import 'colors/app_colors.dart';
import 'elevation/app_elevation.dart';
import '../design/canvas/canvas_theme.dart';
import 'radius/app_radius.dart';
import 'shadows/app_shadows.dart';
import 'sizes/app_sizes.dart';
import 'spacing/app_spacing.dart';
import 'typography/app_typography.dart';

/// OASIS theme configuration.
/// Supports Light, Dark, and High Contrast.
class AppTheme {
  AppTheme._();

  static ThemeData _baseTheme(AppColors colors, CanvasTheme canvasTheme) {
    final colorScheme = ColorScheme(
      brightness: colors.semantic.background.computeLuminance() > 0.5
          ? Brightness.light
          : Brightness.dark,
      primary: colors.semantic.primary,
      onPrimary: colors.semantic.onPrimary,
      secondary: colors.semantic.secondary,
      onSecondary: colors.semantic.onSecondary,
      error: colors.semantic.error,
      onError: colors.semantic.onError,
      surface: colors.semantic.surface,
      onSurface: colors.semantic.onSurface,
      outline: colors.semantic.outline,
    );

    return ThemeData(
      useMaterial3: true,
      fontFamily: 'Inter',
      scaffoldBackgroundColor: colors.semantic.background,
      colorScheme: colorScheme,
      appBarTheme: AppBarTheme(
        backgroundColor: colors.component.appBarBackground,
        foregroundColor: colors.component.appBarForeground,
        iconTheme: IconThemeData(color: colors.component.appBarForeground),
      ),
      iconTheme: IconThemeData(color: colors.semantic.onSurface),
      dividerTheme:
          DividerThemeData(color: colors.semantic.divider, thickness: 0.8),
      cardTheme: CardThemeData(
        color: colors.component.cardBackground,
        shadowColor: colors.semantic.primary.withValues(alpha: 0.18),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(26)),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colors.component.inputBackground,
        hintStyle: TextStyle(color: colors.semantic.textSecondary),
        labelStyle: TextStyle(color: colors.semantic.textSecondary),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: colors.component.inputBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: colors.component.inputBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(
              color: colors.component.inputBorderFocused, width: 1.2),
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: colors.component.fabBackground,
        foregroundColor: colors.component.fabForeground,
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: colors.semantic.surface,
        contentTextStyle: TextStyle(color: colors.semantic.onSurface),
        behavior: SnackBarBehavior.floating,
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: colors.component.navBarBackground,
        selectedItemColor: colors.component.navBarSelected,
        unselectedItemColor: colors.component.navBarUnselected,
      ),
      extensions: [
        colors,
        AppTypography.inter(),
        AppSpacing.defaultSpacing(),
        AppRadius.defaultRadius(),
        AppElevation.light(),
        AppShadows.defaultShadows(),
        AppSizes.defaultSizes(),
        AppAnimations.defaultAnimations(),
        canvasTheme,
      ],
    );
  }

  static ThemeData lightTheme(
          {CanvasTheme canvasTheme = const CanvasTheme()}) =>
      _baseTheme(AppColors.light, canvasTheme);
  static ThemeData darkTheme({CanvasTheme canvasTheme = const CanvasTheme()}) =>
      _baseTheme(AppColors.dark, canvasTheme);
  static ThemeData highContrastLight(
          {CanvasTheme canvasTheme = const CanvasTheme()}) =>
      _baseTheme(AppColors.highContrastLight, canvasTheme);
  static ThemeData highContrastDark(
          {CanvasTheme canvasTheme = const CanvasTheme()}) =>
      _baseTheme(AppColors.highContrastDark, canvasTheme);
}
