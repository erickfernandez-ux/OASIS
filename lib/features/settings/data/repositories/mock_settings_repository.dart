import '../../../../core/utils/local_json_store.dart';
import '../../domain/entities/user_settings.dart';
import '../../domain/enums/canvas_intensity_preference.dart';
import '../../domain/enums/canvas_motion_preference.dart';
import '../../domain/enums/canvas_style_preference.dart';
import '../../domain/enums/theme_mode_preference.dart';
import '../../domain/repositories/settings_repository.dart';

/// In-memory implementation of [SettingsRepository].
class MockSettingsRepository implements SettingsRepository {
  static const _storageKey = 'settings';
  late UserSettings _settings;
  Future<void>? _initFuture;

  MockSettingsRepository() {
    _settings = const UserSettings(
      themeMode: ThemeModePreference.system,
      canvasStyle: CanvasStylePreference.forest,
      canvasIntensity: CanvasIntensityPreference.subtle,
      canvasMotion: CanvasMotionPreference.enabled,
      preferredName: '',
      onboardingCompleted: false,
      language: 'es',
      firstDayOfWeek: 1,
      notificationsEnabled: true,
      highContrast: false,
      privacyLockEnabled: false,
      privacyUsePin: false,
      privacyUseBiometric: false,
      privacyAutoLockMinutes: 0,
      privacyHideInRecents: false,
      privacyRefugeMode: false,
    );
  }

  @override
  Future<UserSettings> getSettings() async {
    await _ensureInitialized();
    await _simulateNetworkDelay();
    return _settings;
  }

  @override
  Future<UserSettings> updateSettings(UserSettings settings) async {
    await _ensureInitialized();
    await _simulateNetworkDelay();
    _settings = settings;
    await _persist();
    return _settings;
  }

  @override
  Future<UserSettings> resetToDefaults() async {
    await _ensureInitialized();
    await _simulateNetworkDelay();
    _settings = const UserSettings();
    await _persist();
    return _settings;
  }

  Future<void> _ensureInitialized() {
    _initFuture ??= _loadFromStorage();
    return _initFuture!;
  }

  Future<void> _loadFromStorage() async {
    final data = await LocalJsonStore.readMap(_storageKey);
    if (data == null) {
      return;
    }

    _settings = UserSettings(
      themeMode: _themeModeFromName(data['themeMode'] as String?),
      canvasStyle: _canvasStyleFromName(data['canvasStyle'] as String?),
      canvasIntensity:
          _canvasIntensityFromName(data['canvasIntensity'] as String?),
      canvasMotion: _canvasMotionFromName(data['canvasMotion'] as String?),
      preferredName: (data['preferredName'] as String?) ?? '',
      onboardingCompleted: (data['onboardingCompleted'] as bool?) ?? false,
      language: (data['language'] as String?) ?? 'es',
      firstDayOfWeek: (data['firstDayOfWeek'] as int?) ?? 1,
      notificationsEnabled: (data['notificationsEnabled'] as bool?) ?? true,
      highContrast: (data['highContrast'] as bool?) ?? false,
      privacyLockEnabled: (data['privacyLockEnabled'] as bool?) ?? false,
      privacyUsePin: (data['privacyUsePin'] as bool?) ?? false,
      privacyUseBiometric: (data['privacyUseBiometric'] as bool?) ?? false,
      privacyAutoLockMinutes: (data['privacyAutoLockMinutes'] as int?) ?? 0,
      privacyHideInRecents:
          (data['privacyHideInRecents'] as bool?) ?? false,
      privacyRefugeMode: (data['privacyRefugeMode'] as bool?) ?? false,
    );
  }

  Future<void> _persist() async {
    await LocalJsonStore.writeMap(_storageKey, {
      'themeMode': _settings.themeMode.name,
      'canvasStyle': _settings.canvasStyle.name,
      'canvasIntensity': _settings.canvasIntensity.name,
      'canvasMotion': _settings.canvasMotion.name,
      'preferredName': _settings.preferredName,
      'onboardingCompleted': _settings.onboardingCompleted,
      'language': _settings.language,
      'firstDayOfWeek': _settings.firstDayOfWeek,
      'notificationsEnabled': _settings.notificationsEnabled,
      'highContrast': _settings.highContrast,
      'privacyLockEnabled': _settings.privacyLockEnabled,
      'privacyUsePin': _settings.privacyUsePin,
      'privacyUseBiometric': _settings.privacyUseBiometric,
      'privacyAutoLockMinutes': _settings.privacyAutoLockMinutes,
      'privacyHideInRecents': _settings.privacyHideInRecents,
      'privacyRefugeMode': _settings.privacyRefugeMode,
    });
  }

  ThemeModePreference _themeModeFromName(String? value) {
    return ThemeModePreference.values.firstWhere(
      (item) => item.name == value,
      orElse: () => ThemeModePreference.system,
    );
  }

  CanvasStylePreference _canvasStyleFromName(String? value) {
    return CanvasStylePreference.values.firstWhere(
      (item) => item.name == value,
      orElse: () => CanvasStylePreference.forest,
    );
  }

  CanvasIntensityPreference _canvasIntensityFromName(String? value) {
    return CanvasIntensityPreference.values.firstWhere(
      (item) => item.name == value,
      orElse: () => CanvasIntensityPreference.subtle,
    );
  }

  CanvasMotionPreference _canvasMotionFromName(String? value) {
    return CanvasMotionPreference.values.firstWhere(
      (item) => item.name == value,
      orElse: () => CanvasMotionPreference.enabled,
    );
  }

  Future<void> _simulateNetworkDelay() async {
    await Future.delayed(const Duration(milliseconds: 100));
  }
}
