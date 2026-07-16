import '../entities/reminder.dart';

/// Contract for Reminder data operations.
abstract class ReminderRepository {
  /// Returns all reminders ordered by trigger time.
  Future<List<Reminder>> getAllReminders();

  /// Returns a single reminder by id, or null if not found.
  Future<Reminder?> getReminderById(String id);

  /// Returns reminders for a specific linked entity.
  Future<List<Reminder>> getRemindersForEntity(String entityId);

  /// Returns pending (non-completed) reminders.
  Future<List<Reminder>> getPendingReminders();

  /// Persists a new reminder.
  Future<Reminder> createReminder(Reminder reminder);

  /// Updates an existing reminder.
  Future<Reminder> updateReminder(Reminder reminder);

  /// Deletes a reminder by id.
  Future<bool> deleteReminder(String id);

  /// Marks a reminder as completed.
  Future<Reminder> markAsCompleted(String id);
}
