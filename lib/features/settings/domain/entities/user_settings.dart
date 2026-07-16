import 'package:equatable/equatable.dart';

import '../enums/canvas_intensity_preference.dart';
import '../enums/canvas_motion_preference.dart';
import '../enums/canvas_style_preference.dart';
import '../enums/theme_mode_preference.dart';

/// Represents the global user configuration that customizes OASIS behavior.
/// This is the cognitive context of the entire system.
class UserSettings extends Equatable {
  final ThemeModePreference themeMode;
  final CanvasStylePreference canvasStyle;
  final CanvasIntensityPreference canvasIntensity;
  final CanvasMotionPreference canvasMotion;
  final String preferredName;
  final bool onboardingCompleted;
  final String language;
  final int firstDayOfWeek;
  final bool notificationsEnabled;
  final bool highContrast;
  final bool privacyLockEnabled;
  final bool privacyUsePin;
  final bool privacyUseBiometric;
  final int privacyAutoLockMinutes;
  final bool privacyHideInRecents;
  final bool privacyRefugeMode;

  const UserSettings({
    this.themeMode = ThemeModePreference.system,
    this.canvasStyle = CanvasStylePreference.forest,
    this.canvasIntensity = CanvasIntensityPreference.subtle,
    this.canvasMotion = CanvasMotionPreference.enabled,
    this.preferredName = '',
    this.onboardingCompleted = false,
    this.language = 'es',
    this.firstDayOfWeek = 1,
    this.notificationsEnabled = true,
    this.highContrast = false,
    this.privacyLockEnabled = false,
    this.privacyUsePin = false,
    this.privacyUseBiometric = false,
    this.privacyAutoLockMinutes = 0,
    this.privacyHideInRecents = false,
    this.privacyRefugeMode = false,
  });

  UserSettings copyWith({
    ThemeModePreference? themeMode,
    CanvasStylePreference? canvasStyle,
    CanvasIntensityPreference? canvasIntensity,
    CanvasMotionPreference? canvasMotion,
    String? preferredName,
    bool? onboardingCompleted,
    String? language,
    int? firstDayOfWeek,
    bool? notificationsEnabled,
    bool? highContrast,
    bool? privacyLockEnabled,
    bool? privacyUsePin,
    bool? privacyUseBiometric,
    int? privacyAutoLockMinutes,
    bool? privacyHideInRecents,
    bool? privacyRefugeMode,
  }) {
    return UserSettings(
      themeMode: themeMode ?? this.themeMode,
      canvasStyle: canvasStyle ?? this.canvasStyle,
      canvasIntensity: canvasIntensity ?? this.canvasIntensity,
      canvasMotion: canvasMotion ?? this.canvasMotion,
      preferredName: preferredName ?? this.preferredName,
      onboardingCompleted: onboardingCompleted ?? this.onboardingCompleted,
      language: language ?? this.language,
      firstDayOfWeek: firstDayOfWeek ?? this.firstDayOfWeek,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      highContrast: highContrast ?? this.highContrast,
      privacyLockEnabled: privacyLockEnabled ?? this.privacyLockEnabled,
      privacyUsePin: privacyUsePin ?? this.privacyUsePin,
      privacyUseBiometric: privacyUseBiometric ?? this.privacyUseBiometric,
      privacyAutoLockMinutes:
          privacyAutoLockMinutes ?? this.privacyAutoLockMinutes,
      privacyHideInRecents:
          privacyHideInRecents ?? this.privacyHideInRecents,
      privacyRefugeMode: privacyRefugeMode ?? this.privacyRefugeMode,
    );
  }

  @override
  List<Object?> get props => [
        themeMode,
        canvasStyle,
        canvasIntensity,
        canvasMotion,
        preferredName,
        onboardingCompleted,
        language,
        firstDayOfWeek,
        notificationsEnabled,
        highContrast,
        privacyLockEnabled,
        privacyUsePin,
        privacyUseBiometric,
        privacyAutoLockMinutes,
        privacyHideInRecents,
        privacyRefugeMode,
      ];

  @override
  String toString() =>
      'UserSettings(themeMode: $themeMode, language: $language)';
}
