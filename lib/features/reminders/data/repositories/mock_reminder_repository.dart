import 'package:uuid/uuid.dart';

import '../../domain/entities/reminder.dart';
import '../../domain/enums/reminder_repeat.dart';
import '../../domain/repositories/reminder_repository.dart';

/// In-memory implementation of [ReminderRepository].
class MockReminderRepository implements ReminderRepository {
  final List<Reminder> _reminders = [];
  final _uuid = const Uuid();

  MockReminderRepository() {
    _seedData();
  }

  void _seedData() {
    final now = DateTime.now();
    _reminders.addAll([
      Reminder(
        id: _uuid.v4(),
        title: 'Tomar medicamento: Sertralina',
        dateTime: now.add(const Duration(hours: 1)),
        repeatRule: ReminderRepeat.daily,
      ),
      Reminder(
        id: _uuid.v4(),
        title: 'Llamar a mamá',
        dateTime: now.add(const Duration(days: 1, hours: 18)),
        repeatRule: ReminderRepeat.weekly,
      ),
      Reminder(
        id: _uuid.v4(),
        title: 'Revisar presupuesto mensual',
        dateTime: now.add(const Duration(days: 5)),
        repeatRule: ReminderRepeat.monthly,
      ),
    ]);
  }

  @override
  Future<List<Reminder>> getAllReminders() async {
    await _simulateNetworkDelay();
    return List.unmodifiable(_reminders..sort((a, b) => a.dateTime.compareTo(b.dateTime)));
  }

  @override
  Future<Reminder?> getReminderById(String id) async {
    await _simulateNetworkDelay();
    try {
      return _reminders.firstWhere((r) => r.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<List<Reminder>> getRemindersForEntity(String entityId) async {
    await _simulateNetworkDelay();
    return _reminders.where((r) => r.title.contains(entityId)).toList();
  }

  @override
  Future<List<Reminder>> getPendingReminders() async {
    await _simulateNetworkDelay();
    return _reminders.where((r) => !r.isCompleted).toList();
  }

  @override
  Future<Reminder> createReminder(Reminder reminder) async {
    await _simulateNetworkDelay();
    final created = reminder.copyWith(id: reminder.id.isEmpty ? _uuid.v4() : reminder.id);
    _reminders.add(created);
    return created;
  }

  @override
  Future<Reminder> updateReminder(Reminder reminder) async {
    await _simulateNetworkDelay();
    final index = _reminders.indexWhere((r) => r.id == reminder.id);
    if (index == -1) throw Exception('Reminder not found: ${reminder.id}');
    _reminders[index] = reminder;
    return reminder;
  }

  @override
  Future<bool> deleteReminder(String id) async {
    await _simulateNetworkDelay();
    final index = _reminders.indexWhere((r) => r.id == id);
    if (index == -1) return false;
    _reminders.removeAt(index);
    return true;
  }

  @override
  Future<Reminder> markAsCompleted(String id) async {
    await _simulateNetworkDelay();
    final index = _reminders.indexWhere((r) => r.id == id);
    if (index == -1) throw Exception('Reminder not found: $id');
    final updated = _reminders[index].copyWith(isCompleted: true);
    _reminders[index] = updated;
    return updated;
  }

  Future<void> _simulateNetworkDelay() async {
    await Future.delayed(const Duration(milliseconds: 150));
  }
}
