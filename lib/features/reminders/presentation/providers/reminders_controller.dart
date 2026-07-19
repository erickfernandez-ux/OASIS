import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/di/usecase_providers.dart';
import '../../domain/entities/reminder.dart';
import '../../domain/enums/reminder_repeat.dart';

/// Controls the state and operations of the Reminders feature.
class RemindersController extends AsyncNotifier<List<Reminder>> {
  @override
  Future<List<Reminder>> build() async {
    return _fetchReminders();
  }

  Future<List<Reminder>> _fetchReminders() async {
    final getReminders = ref.read(getRemindersProvider);
    return getReminders();
  }

  /// Creates a new reminder.
  Future<void> createReminder({
    required String title,
    required DateTime dateTime,
    required ReminderRepeat repeatRule,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final createReminder = ref.read(createReminderProvider);
      await createReminder(
        title: title,
        dateTime: dateTime,
        repeatRule: repeatRule,
      );
      return _fetchReminders();
    });
  }

  /// Updates an existing reminder.
  Future<void> updateReminder(Reminder reminder) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final updateReminder = ref.read(updateReminderProvider);
      await updateReminder(reminder);
      return _fetchReminders();
    });
  }

  /// Deletes a reminder.
  Future<void> deleteReminder(String id) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final deleteReminder = ref.read(deleteReminderProvider);
      await deleteReminder(id);
      return _fetchReminders();
    });
  }

  /// Refreshes the reminders list.
  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(_fetchReminders);
  }
}

final remindersControllerProvider =
    AsyncNotifierProvider<RemindersController, List<Reminder>>(() {
  return RemindersController();
});
