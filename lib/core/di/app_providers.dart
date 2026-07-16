import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../config/app_config.dart';
import '../../features/settings/presentation/providers/settings_controller.dart';
import '../../features/settings/domain/enums/theme_mode_preference.dart';
import '../design/canvas/canvas_theme.dart';
import '../../features/settings/domain/entities/user_settings.dart';

// ---------------------------------------------------------------------------
// App-Level Global Providers
// ---------------------------------------------------------------------------
// These providers expose the application shell state and configuration.
// They contain no business logic.
// ---------------------------------------------------------------------------

/// Controls the visual theme mode of the application.
final themeModeProvider = Provider<ThemeMode>((ref) {
  final mode = ref.watch(
    settingsControllerProvider.select(
      (state) => state.valueOrNull?.themeMode ?? ThemeModePreference.system,
    ),
  );
  return switch (mode) {
    ThemeModePreference.light => ThemeMode.light,
    ThemeModePreference.dark => ThemeMode.dark,
    ThemeModePreference.system => ThemeMode.system,
  };
});

/// Controls the living canvas style and intensity.
final canvasThemeProvider = Provider<CanvasTheme>((ref) {
  final style = ref.watch(
    settingsControllerProvider.select(
      (state) =>
          state.valueOrNull?.canvasStyle ?? const UserSettings().canvasStyle,
    ),
  );
  final intensity = ref.watch(
    settingsControllerProvider.select(
      (state) =>
          state.valueOrNull?.canvasIntensity ??
          const UserSettings().canvasIntensity,
    ),
  );
  final motion = ref.watch(
    settingsControllerProvider.select(
      (state) =>
          state.valueOrNull?.canvasMotion ?? const UserSettings().canvasMotion,
    ),
  );

  return CanvasTheme.fromPreferences(
    style: style,
    intensity: intensity,
    motion: motion,
  );
});

/// Provides the current date for UI and feature layers.
final currentDateProvider = Provider<DateTime>((ref) {
  return DateTime.now();
});

/// Exposes application configuration constants.
final appConfigProvider = Provider<AppConfig>((ref) {
  return const AppConfig();
});
