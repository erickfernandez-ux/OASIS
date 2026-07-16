import '../repositories/reminder_repository.dart';

/// Permanently removes a reminder.
class DeleteReminder {
  final ReminderRepository _repository;

  const DeleteReminder(this._repository);

  Future<bool> call(String id) async {
    return _repository.deleteReminder(id);
  }
}
