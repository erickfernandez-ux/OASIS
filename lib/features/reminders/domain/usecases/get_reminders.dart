import '../entities/reminder.dart';
import '../repositories/reminder_repository.dart';

/// Retrieves all reminders ordered by trigger time.
class GetReminders {
  final ReminderRepository _repository;

  const GetReminders(this._repository);

  Future<List<Reminder>> call() async {
    return _repository.getAllReminders();
  }
}
