import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/agenda/domain/usecases/complete_task.dart';
import '../../features/agenda/domain/usecases/create_task.dart';
import '../../features/agenda/domain/usecases/delete_task.dart';
import '../../features/agenda/domain/usecases/get_all_tasks.dart';
import '../../features/agenda/domain/usecases/get_task.dart';
import '../../features/agenda/domain/usecases/uncomplete_task.dart';
import '../../features/agenda/domain/usecases/update_task.dart';
import '../../features/calendar/domain/usecases/create_event.dart';
import '../../features/calendar/domain/usecases/delete_event.dart';
import '../../features/calendar/domain/usecases/get_events.dart';
import '../../features/calendar/domain/usecases/update_event.dart';
import '../../features/habits/domain/usecases/complete_habit.dart';
import '../../features/habits/domain/usecases/create_habit.dart';
import '../../features/habits/domain/usecases/delete_habit.dart';
import '../../features/habits/domain/usecases/get_habits.dart';
import '../../features/habits/domain/usecases/update_habit.dart';
import '../../features/journal/domain/usecases/create_journal_entry.dart';
import '../../features/journal/domain/usecases/delete_journal_entry.dart';
import '../../features/journal/domain/usecases/get_all_journal_entries.dart';
import '../../features/journal/domain/usecases/get_journal_entry.dart';
import '../../features/journal/domain/usecases/update_journal_entry.dart';
import '../../features/medications/domain/usecases/create_medication.dart';
import '../../features/medications/domain/usecases/delete_medication.dart';
import '../../features/medications/domain/usecases/get_medications.dart';
import '../../features/medications/domain/usecases/mark_medication_taken.dart';
import '../../features/medications/domain/usecases/update_medication.dart';
import '../../features/notes/domain/usecases/create_note.dart';
import '../../features/notes/domain/usecases/delete_note.dart';
import '../../features/notes/domain/usecases/get_all_notes.dart';
import '../../features/notes/domain/usecases/get_note.dart';
import '../../features/notes/domain/usecases/update_note.dart';
import '../../features/notes/domain/usecases/toggle_favorite.dart';
import '../../features/reminders/domain/usecases/create_reminder.dart';
import '../../features/reminders/domain/usecases/delete_reminder.dart';
import '../../features/reminders/domain/usecases/get_reminders.dart';
import '../../features/reminders/domain/usecases/update_reminder.dart';
import '../../features/settings/domain/usecases/get_settings.dart';
import '../../features/settings/domain/usecases/update_settings.dart';
import '../../features/safety_plan/domain/usecases/get_safety_plan.dart';
import '../../features/safety_plan/domain/usecases/set_crisis_mode.dart';
import '../../features/safety_plan/domain/usecases/update_safety_plan.dart';
import '../../features/wellbeing/domain/usecases/create_mood_entry.dart';
import '../../features/wellbeing/domain/usecases/get_daily_water.dart';
import '../../features/wellbeing/domain/usecases/get_mood_history.dart';
import '../../features/wellbeing/domain/usecases/register_water_intake.dart';
import 'repository_providers.dart';

// ---------------------------------------------------------------------------
// Use Case Providers
// ---------------------------------------------------------------------------
// Each Use Case receives its Repository via Riverpod.
// No manual instantiation. All dependencies are resolved through the container.
// ---------------------------------------------------------------------------

// ─── Agenda Use Cases ───────────────────────────────────────────────────────

final createTaskProvider = Provider<CreateTask>((ref) {
  return CreateTask(ref.watch(taskRepositoryProvider));
});

final updateTaskProvider = Provider<UpdateTask>((ref) {
  return UpdateTask(ref.watch(taskRepositoryProvider));
});

final deleteTaskProvider = Provider<DeleteTask>((ref) {
  return DeleteTask(ref.watch(taskRepositoryProvider));
});

final getTaskProvider = Provider<GetTask>((ref) {
  return GetTask(ref.watch(taskRepositoryProvider));
});

final getAllTasksProvider = Provider<GetAllTasks>((ref) {
  return GetAllTasks(ref.watch(taskRepositoryProvider));
});

final completeTaskProvider = Provider<CompleteTask>((ref) {
  return CompleteTask(ref.watch(taskRepositoryProvider));
});

final uncompleteTaskProvider = Provider<UncompleteTask>((ref) {
  return UncompleteTask(ref.watch(taskRepositoryProvider));
});

// ─── Journal Use Cases ─────────────────────────────────────────────────────

final createJournalEntryProvider = Provider<CreateJournalEntry>((ref) {
  return CreateJournalEntry(ref.watch(journalRepositoryProvider));
});

final updateJournalEntryProvider = Provider<UpdateJournalEntry>((ref) {
  return UpdateJournalEntry(ref.watch(journalRepositoryProvider));
});

final deleteJournalEntryProvider = Provider<DeleteJournalEntry>((ref) {
  return DeleteJournalEntry(ref.watch(journalRepositoryProvider));
});

final getAllJournalEntriesProvider = Provider<GetAllJournalEntries>((ref) {
  return GetAllJournalEntries(ref.watch(journalRepositoryProvider));
});

final getJournalEntryProvider = Provider<GetJournalEntry>((ref) {
  return GetJournalEntry(ref.watch(journalRepositoryProvider));
});

// ─── Calendar Use Cases ─────────────────────────────────────────────────────

final createEventProvider = Provider<CreateEvent>((ref) {
  return CreateEvent(ref.watch(eventRepositoryProvider));
});

final updateEventProvider = Provider<UpdateEvent>((ref) {
  return UpdateEvent(ref.watch(eventRepositoryProvider));
});

final deleteEventProvider = Provider<DeleteEvent>((ref) {
  return DeleteEvent(ref.watch(eventRepositoryProvider));
});

final getEventsProvider = Provider<GetEvents>((ref) {
  return GetEvents(ref.watch(eventRepositoryProvider));
});

// ─── Notes Use Cases ────────────────────────────────────────────────────────

final createNoteProvider = Provider<CreateNote>((ref) {
  return CreateNote(ref.watch(noteRepositoryProvider));
});

final updateNoteProvider = Provider<UpdateNote>((ref) {
  return UpdateNote(ref.watch(noteRepositoryProvider));
});

final deleteNoteProvider = Provider<DeleteNote>((ref) {
  return DeleteNote(ref.watch(noteRepositoryProvider));
});

final getNoteProvider = Provider<GetNote>((ref) {
  return GetNote(ref.watch(noteRepositoryProvider));
});

final getAllNotesProvider = Provider<GetAllNotes>((ref) {
  return GetAllNotes(ref.watch(noteRepositoryProvider));
});

final toggleFavoriteProvider = Provider<ToggleFavorite>((ref) {
  return ToggleFavorite(ref.watch(noteRepositoryProvider));
});

// ─── Reminders Use Cases ────────────────────────────────────────────────────

final createReminderProvider = Provider<CreateReminder>((ref) {
  return CreateReminder(ref.watch(reminderRepositoryProvider));
});

final updateReminderProvider = Provider<UpdateReminder>((ref) {
  return UpdateReminder(ref.watch(reminderRepositoryProvider));
});

final deleteReminderProvider = Provider<DeleteReminder>((ref) {
  return DeleteReminder(ref.watch(reminderRepositoryProvider));
});

final getRemindersProvider = Provider<GetReminders>((ref) {
  return GetReminders(ref.watch(reminderRepositoryProvider));
});

// ─── Medications Use Cases ──────────────────────────────────────────────────

final createMedicationProvider = Provider<CreateMedication>((ref) {
  return CreateMedication(ref.watch(medicationRepositoryProvider));
});

final updateMedicationProvider = Provider<UpdateMedication>((ref) {
  return UpdateMedication(ref.watch(medicationRepositoryProvider));
});

final deleteMedicationProvider = Provider<DeleteMedication>((ref) {
  return DeleteMedication(ref.watch(medicationRepositoryProvider));
});

final getMedicationsProvider = Provider<GetMedications>((ref) {
  return GetMedications(ref.watch(medicationRepositoryProvider));
});

final markMedicationTakenProvider = Provider<MarkMedicationTaken>((ref) {
  return MarkMedicationTaken(ref.watch(medicationRepositoryProvider));
});

// ─── Habits Use Cases ───────────────────────────────────────────────────────

final createHabitProvider = Provider<CreateHabit>((ref) {
  return CreateHabit(ref.watch(habitRepositoryProvider));
});

final updateHabitProvider = Provider<UpdateHabit>((ref) {
  return UpdateHabit(ref.watch(habitRepositoryProvider));
});

final deleteHabitProvider = Provider<DeleteHabit>((ref) {
  return DeleteHabit(ref.watch(habitRepositoryProvider));
});

final getHabitsProvider = Provider<GetHabits>((ref) {
  return GetHabits(ref.watch(habitRepositoryProvider));
});

final completeHabitProvider = Provider<CompleteHabit>((ref) {
  return CompleteHabit(ref.watch(habitRepositoryProvider));
});

// ─── Wellbeing Use Cases ────────────────────────────────────────────────────

final createMoodEntryProvider = Provider<CreateMoodEntry>((ref) {
  return CreateMoodEntry(ref.watch(moodRepositoryProvider));
});

final getMoodHistoryProvider = Provider<GetMoodHistory>((ref) {
  return GetMoodHistory(ref.watch(moodRepositoryProvider));
});

final registerWaterIntakeProvider = Provider<RegisterWaterIntake>((ref) {
  return const RegisterWaterIntake();
});

final getDailyWaterProvider = Provider<GetDailyWater>((ref) {
  return const GetDailyWater();
});

// ─── Settings Use Cases ─────────────────────────────────────────────────────

final getSettingsProvider = Provider<GetSettings>((ref) {
  return GetSettings(ref.watch(settingsRepositoryProvider));
});

final updateSettingsProvider = Provider<UpdateSettings>((ref) {
  return UpdateSettings(ref.watch(settingsRepositoryProvider));
});

// ─── Safety Plan Use Cases ──────────────────────────────────────────────────

final getSafetyPlanProvider = Provider<GetSafetyPlan>((ref) {
  return GetSafetyPlan(ref.watch(safetyPlanRepositoryProvider));
});

final updateSafetyPlanProvider = Provider<UpdateSafetyPlan>((ref) {
  return UpdateSafetyPlan(ref.watch(safetyPlanRepositoryProvider));
});

final setCrisisModeProvider = Provider<SetCrisisMode>((ref) {
  return SetCrisisMode(ref.watch(safetyPlanRepositoryProvider));
});
