import '../entities/reminder.dart';
import '../enums/reminder_repeat.dart';
import '../repositories/reminder_repository.dart';

/// Creates a new reminder linked to an entity.
class CreateReminder {
  final ReminderRepository _repository;

  const CreateReminder(this._repository);

  Future<Reminder> call({
    required String title,
    required DateTime dateTime,
    ReminderRepeat repeatRule = ReminderRepeat.once,
    bool isCompleted = false,
  }) async {
    final reminder = Reminder(
      id: '',
      title: title,
      dateTime: dateTime,
      repeatRule: repeatRule,
      isCompleted: isCompleted,
    );
    return _repository.createReminder(reminder);
  }
}
