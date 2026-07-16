import '../entities/user_settings.dart';
import '../repositories/settings_repository.dart';

/// Retrieves the current user settings.
class GetSettings {
  final SettingsRepository _repository;

  const GetSettings(this._repository);

  Future<UserSettings> call() async {
    return _repository.getSettings();
  }
}
