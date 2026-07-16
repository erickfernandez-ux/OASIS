import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/agenda/data/repositories/mock_task_repository.dart';
import '../../features/agenda/domain/repositories/task_repository.dart';
import '../../features/calendar/data/repositories/mock_event_repository.dart';
import '../../features/calendar/domain/repositories/event_repository.dart';
import '../../features/habits/data/repositories/mock_habit_repository.dart';
import '../../features/habits/domain/repositories/habit_repository.dart';
import '../../features/journal/data/repositories/mock_journal_repository.dart';
import '../../features/journal/domain/repositories/journal_repository.dart';
import '../../features/medications/data/repositories/mock_medication_repository.dart';
import '../../features/medications/domain/repositories/medication_repository.dart';
import '../../features/notes/data/repositories/mock_note_repository.dart';
import '../../features/notes/domain/repositories/note_repository.dart';
import '../../features/reminders/data/repositories/mock_reminder_repository.dart';
import '../../features/reminders/domain/repositories/reminder_repository.dart';
import '../../features/settings/data/repositories/mock_settings_repository.dart';
import '../../features/settings/domain/repositories/settings_repository.dart';
import '../../features/safety_plan/data/repositories/mock_safety_plan_repository.dart';
import '../../features/safety_plan/domain/repositories/safety_plan_repository.dart';
import '../../features/wellbeing/data/repositories/mock_mood_repository.dart';
import '../../features/wellbeing/domain/repositories/mood_repository.dart';

// ---------------------------------------------------------------------------
// Repository Providers
// ---------------------------------------------------------------------------
// These providers instantiate Mock Repositories.
// In the future, replacing a Mock with a Supabase implementation only requires
// changing the provider body. No changes needed in Use Cases, Controllers, or UI.
// ---------------------------------------------------------------------------

/// Provides [TaskRepository] via [MockTaskRepository].
final taskRepositoryProvider = Provider<TaskRepository>((ref) {
  return MockTaskRepository();
});

/// Provides [EventRepository] via [MockEventRepository].
final eventRepositoryProvider = Provider<EventRepository>((ref) {
  return MockEventRepository();
});

/// Provides [NoteRepository] via [MockNoteRepository].
final noteRepositoryProvider = Provider<NoteRepository>((ref) {
  return MockNoteRepository();
});

/// Provides [ReminderRepository] via [MockReminderRepository].
final reminderRepositoryProvider = Provider<ReminderRepository>((ref) {
  return MockReminderRepository();
});

/// Provides [MedicationRepository] via [MockMedicationRepository].
final medicationRepositoryProvider = Provider<MedicationRepository>((ref) {
  return MockMedicationRepository();
});

/// Provides [HabitRepository] via [MockHabitRepository].
final habitRepositoryProvider = Provider<HabitRepository>((ref) {
  return MockHabitRepository();
});

/// Provides [JournalRepository] via [MockJournalRepository].
final journalRepositoryProvider = Provider<JournalRepository>((ref) {
  return MockJournalRepository();
});

/// Provides [MoodRepository] via [MockMoodRepository].
final moodRepositoryProvider = Provider<MoodRepository>((ref) {
  return MockMoodRepository();
});

/// Provides [SettingsRepository] via [MockSettingsRepository].
final settingsRepositoryProvider = Provider<SettingsRepository>((ref) {
  return MockSettingsRepository();
});

/// Provides [SafetyPlanRepository] via [MockSafetyPlanRepository].
final safetyPlanRepositoryProvider = Provider<SafetyPlanRepository>((ref) {
  return MockSafetyPlanRepository();
});
