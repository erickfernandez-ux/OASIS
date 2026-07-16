import '../entities/reminder.dart';
import '../repositories/reminder_repository.dart';

/// Updates an existing reminder.
class UpdateReminder {
  final ReminderRepository _repository;

  const UpdateReminder(this._repository);

  Future<Reminder> call(Reminder reminder) async {
    return _repository.updateReminder(reminder);
  }
}
