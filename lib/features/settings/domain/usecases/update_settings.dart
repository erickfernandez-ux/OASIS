import '../entities/user_settings.dart';
import '../repositories/settings_repository.dart';

/// Updates the user settings.
class UpdateSettings {
  final SettingsRepository _repository;

  const UpdateSettings(this._repository);

  Future<UserSettings> call(UserSettings settings) async {
    return _repository.updateSettings(settings);
  }
}
