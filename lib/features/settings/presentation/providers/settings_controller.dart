import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/di/usecase_providers.dart';
import '../../domain/entities/user_settings.dart';
import '../../domain/enums/canvas_intensity_preference.dart';
import '../../domain/enums/canvas_motion_preference.dart';
import '../../domain/enums/canvas_style_preference.dart';
import '../../domain/enums/theme_mode_preference.dart';

/// Controls the state and operations of the Settings feature.
class SettingsController extends AsyncNotifier<UserSettings> {
  @override
  Future<UserSettings> build() async {
    return _fetchSettings();
  }

  Future<UserSettings> _fetchSettings() async {
    final getSettings = ref.read(getSettingsProvider);
    return getSettings();
  }

  /// Updates the theme mode.
  Future<void> setThemeMode(ThemeModePreference mode) async {
    state = await AsyncValue.guard(() async {
      final current = state.value;
      if (current == null) return _fetchSettings();

      final updateSettings = ref.read(updateSettingsProvider);
      await updateSettings(current.copyWith(themeMode: mode));
      return _fetchSettings();
    });
  }

  Future<void> setCanvasStyle(CanvasStylePreference style) async {
    state = await AsyncValue.guard(() async {
      final current = state.value;
      if (current == null) return _fetchSettings();

      final updateSettings = ref.read(updateSettingsProvider);
      await updateSettings(current.copyWith(canvasStyle: style));
      return _fetchSettings();
    });
  }

  Future<void> setCanvasIntensity(CanvasIntensityPreference intensity) async {
    state = await AsyncValue.guard(() async {
      final current = state.value;
      if (current == null) return _fetchSettings();

      final updateSettings = ref.read(updateSettingsProvider);
      await updateSettings(current.copyWith(canvasIntensity: intensity));
      return _fetchSettings();
    });
  }

  Future<void> setCanvasMotion(CanvasMotionPreference motion) async {
    state = await AsyncValue.guard(() async {
      final current = state.value;
      if (current == null) return _fetchSettings();

      final updateSettings = ref.read(updateSettingsProvider);
      await updateSettings(current.copyWith(canvasMotion: motion));
      return _fetchSettings();
    });
  }

  Future<void> setPreferredName(String name) async {
    final normalizedName = name.trim();
    final current = state.valueOrNull ?? await _fetchSettings();

    if (normalizedName.isEmpty) {
      state = AsyncData(current);
      return;
    }

    final result = await AsyncValue.guard(() async {
      final updateSettings = ref.read(updateSettingsProvider);
      await updateSettings(current.copyWith(preferredName: normalizedName));
      return _fetchSettings();
    });

    state = result.hasError ? AsyncData(current) : result;
  }

  Future<void> completeOnboarding() async {
    state = await AsyncValue.guard(() async {
      final current = state.value;
      if (current == null) return _fetchSettings();

      final updateSettings = ref.read(updateSettingsProvider);
      await updateSettings(current.copyWith(onboardingCompleted: true));
      return _fetchSettings();
    });
  }

  /// Toggles high contrast mode.
  Future<void> toggleHighContrast() async {
    state = await AsyncValue.guard(() async {
      final current = state.value;
      if (current == null) return _fetchSettings();

      final updateSettings = ref.read(updateSettingsProvider);
      await updateSettings(
          current.copyWith(highContrast: !current.highContrast));
      return _fetchSettings();
    });
  }

  /// Refreshes settings.
  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(_fetchSettings);
  }

  Future<void> saveSettings(UserSettings settings) async {
    state = await AsyncValue.guard(() async {
      final updateSettings = ref.read(updateSettingsProvider);
      await updateSettings(settings);
      return _fetchSettings();
    });
  }
}

final settingsControllerProvider =
    AsyncNotifierProvider<SettingsController, UserSettings>(() {
  return SettingsController();
});
