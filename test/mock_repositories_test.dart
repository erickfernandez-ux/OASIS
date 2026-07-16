import 'package:flutter_test/flutter_test.dart';
import 'package:oasis/features/agenda/data/repositories/mock_task_repository.dart';
import 'package:oasis/features/agenda/domain/entities/task.dart';
import 'package:oasis/features/agenda/domain/enums/task_priority.dart';
import 'package:oasis/features/agenda/domain/enums/task_status.dart';
import 'package:oasis/features/calendar/data/repositories/mock_event_repository.dart';
import 'package:oasis/features/calendar/domain/entities/event.dart';
import 'package:oasis/features/habits/data/repositories/mock_habit_repository.dart';
import 'package:oasis/features/habits/domain/entities/habit.dart';
import 'package:oasis/features/habits/domain/enums/habit_frequency.dart';
import 'package:oasis/features/medications/data/repositories/mock_medication_repository.dart';
import 'package:oasis/features/medications/domain/entities/medication.dart';
import 'package:oasis/features/medications/domain/value_objects/dosage.dart';
import 'package:oasis/features/notes/data/repositories/mock_note_repository.dart';
import 'package:oasis/features/notes/domain/entities/note.dart';
import 'package:oasis/features/reminders/data/repositories/mock_reminder_repository.dart';
import 'package:oasis/features/reminders/domain/entities/reminder.dart';
import 'package:oasis/features/settings/data/repositories/mock_settings_repository.dart';
import 'package:oasis/features/wellbeing/data/repositories/mock_mood_repository.dart';
import 'package:oasis/features/wellbeing/domain/entities/mood_entry.dart';
import 'package:oasis/features/wellbeing/domain/enums/mood_type.dart';

void main() {
  group('mock repositories', () {
    test('Task repository supports create, read, update and delete', () async {
      final repository = MockTaskRepository();
      final created = await repository.createTask(
        Task(
          id: '',
          title: 'Review sprint',
          createdAt: DateTime(2026, 6, 30),
          updatedAt: DateTime(2026, 6, 30),
        ),
      );

      expect(created.id, isNotEmpty);
      final fetched = await repository.getTaskById(created.id);
      expect(fetched?.title, 'Review sprint');

      final updated = await repository.updateTask(
        created.copyWith(status: TaskStatus.inProgress, priority: TaskPriority.high),
      );
      expect(updated.status, TaskStatus.inProgress);

      final deleted = await repository.deleteTask(created.id);
      expect(deleted, isTrue);
      expect(await repository.getTaskById(created.id), isNull);
    });

    test('Note repository supports create, read, update and delete', () async {
      final repository = MockNoteRepository();
      final created = await repository.createNote(
        Note(id: '', content: 'Draft', createdAt: DateTime(2026, 6, 30), updatedAt: DateTime(2026, 6, 30)),
      );

      expect(created.id, isNotEmpty);
      final fetched = await repository.getNoteById(created.id);
      expect(fetched?.content, 'Draft');

      final updated = await repository.updateNote(created.copyWith(content: 'Updated', isFavorite: true));
      expect(updated.content, 'Updated');
      expect(updated.isFavorite, isTrue);

      final deleted = await repository.deleteNote(created.id);
      expect(deleted, isTrue);
      expect(await repository.getNoteById(created.id), isNull);
    });

    test('Event repository supports create, read, update and delete', () async {
      final repository = MockEventRepository();
      final created = await repository.createEvent(
        Event(
          id: '',
          title: 'Planning',
          startDateTime: DateTime(2026, 6, 30, 10),
          endDateTime: DateTime(2026, 6, 30, 11),
          createdAt: DateTime(2026, 6, 30),
        ),
      );

      expect(created.id, isNotEmpty);
      final fetched = await repository.getEventById(created.id);
      expect(fetched?.title, 'Planning');

      final updated = await repository.updateEvent(created.copyWith(title: 'Replanning'));
      expect(updated.title, 'Replanning');

      final deleted = await repository.deleteEvent(created.id);
      expect(deleted, isTrue);
      expect(await repository.getEventById(created.id), isNull);
    });

    test('Habit repository supports create, read, update and delete', () async {
      final repository = MockHabitRepository();
      final created = await repository.createHabit(
        Habit(
          id: '',
          title: 'Hydration',
          frequency: HabitFrequency.daily,
          goal: '8 glasses',
          createdAt: DateTime(2026, 6, 30),
        ),
      );

      expect(created.id, isNotEmpty);
      final fetched = await repository.getHabitById(created.id);
      expect(fetched?.goal, '8 glasses');

      final updated = await repository.updateHabit(created.copyWith(goal: '10 glasses'));
      expect(updated.goal, '10 glasses');

      final deleted = await repository.deleteHabit(created.id);
      expect(deleted, isTrue);
      expect(await repository.getHabitById(created.id), isNull);
    });

    test('Medication repository supports create, read, update and delete', () async {
      final repository = MockMedicationRepository();
      final created = await repository.createMedication(
        const Medication(
          id: '',
          name: 'Vitamin D',
          dosage: Dosage(amount: 1, unit: DosageUnit.tablet),
          schedule: ['08:00'],
        ),
      );

      expect(created.id, isNotEmpty);
      final fetched = await repository.getMedicationById(created.id);
      expect(fetched?.name, 'Vitamin D');

      final updated = await repository.updateMedication(created.copyWith(isActive: false));
      expect(updated.isActive, isFalse);

      final deleted = await repository.deleteMedication(created.id);
      expect(deleted, isTrue);
      expect(await repository.getMedicationById(created.id), isNull);
    });

    test('Mood repository supports create, read, update and delete', () async {
      final repository = MockMoodRepository();
      final created = await repository.createEntry(
        MoodEntry(id: '', mood: MoodType.neutral, date: DateTime(2026, 6, 30)),
      );

      expect(created.id, isNotEmpty);
      final fetched = await repository.getEntryById(created.id);
      expect(fetched?.mood, MoodType.neutral);

      final updated = await repository.updateEntry(created.copyWith(mood: MoodType.happy));
      expect(updated.mood, MoodType.happy);

      final deleted = await repository.deleteEntry(created.id);
      expect(deleted, isTrue);
      expect(await repository.getEntryById(created.id), isNull);
    });

    test('Reminder repository supports create, read, update and delete', () async {
      final repository = MockReminderRepository();
      final created = await repository.createReminder(
        Reminder(
          id: '',
          title: 'Take a break',
          dateTime: DateTime(2026, 6, 30, 15),
        ),
      );

      expect(created.id, isNotEmpty);
      final fetched = await repository.getReminderById(created.id);
      expect(fetched?.title, 'Take a break');

      final updated = await repository.updateReminder(created.copyWith(title: 'Stretch break'));
      expect(updated.title, 'Stretch break');

      final deleted = await repository.deleteReminder(created.id);
      expect(deleted, isTrue);
      expect(await repository.getReminderById(created.id), isNull);
    });

    test('Settings repository supports default read and update', () async {
      final repository = MockSettingsRepository();
      final settings = await repository.getSettings();
      expect(settings.language, 'es');

      final updated = await repository.updateSettings(settings.copyWith(language: 'en'));
      expect(updated.language, 'en');

      final reset = await repository.resetToDefaults();
      expect(reset.language, 'es');
    });
  });
}
