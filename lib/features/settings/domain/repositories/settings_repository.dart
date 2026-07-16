import '../entities/user_settings.dart';

/// Contract for UserSettings data operations.
abstract class SettingsRepository {
  /// Returns the current user settings.
  /// There is only one settings record per user.
  Future<UserSettings> getSettings();

  /// Updates the user settings.
  Future<UserSettings> updateSettings(UserSettings settings);

  /// Resets settings to defaults.
  Future<UserSettings> resetToDefaults();
}
