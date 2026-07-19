import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/di/di.dart';
import '../../../../core/utils/local_json_store.dart';
import '../../../agenda/domain/enums/task_priority.dart';
import '../../../agenda/domain/enums/task_status.dart';
import '../../../agenda/domain/entities/task.dart';
import '../../../agenda/domain/repositories/task_repository.dart';
import '../../../calendar/domain/repositories/event_repository.dart';
import '../../../journal/domain/repositories/journal_repository.dart';
import '../../../medications/domain/entities/medication.dart';
import '../../../medications/domain/repositories/medication_repository.dart';
import '../../../notes/domain/repositories/note_repository.dart';
import '../../../wellbeing/domain/entities/water_entry.dart';
import '../../../wellbeing/domain/enums/mood_type.dart';
import '../../../wellbeing/domain/repositories/mood_repository.dart';
import '../../../wellbeing/domain/usecases/get_daily_water.dart';

class HomeDashboardData {
  final int pendingTasksCount;
  final int todayEventsCount;
  final String? nextMedicationName;
  final String? nextMedicationDoseLabel;
  final String? nextMedicationTimeLabel;
  final String? nextMedicationStatusLabel;
  final int completedTasksCount;
  final int waterConsumedMl;
  final String moodLabel;
  final String? energyLabel;
  final int pomodoroSessions;
  final bool journalUsedYesterday;
  final String? latestNoteLabel;
  final String? latestTaskLabel;
  final String? latestJournalLabel;
  final HomeTaskItem? priorityTask;
  final List<HomeEventItem> todayEvents;
  final List<HomeTaskItem> upcomingTasks;

  const HomeDashboardData({
    required this.pendingTasksCount,
    required this.todayEventsCount,
    required this.nextMedicationName,
    required this.nextMedicationDoseLabel,
    required this.nextMedicationTimeLabel,
    required this.nextMedicationStatusLabel,
    required this.completedTasksCount,
    required this.waterConsumedMl,
    required this.moodLabel,
    required this.energyLabel,
    required this.pomodoroSessions,
    required this.journalUsedYesterday,
    required this.latestNoteLabel,
    required this.latestTaskLabel,
    required this.latestJournalLabel,
    required this.priorityTask,
    required this.todayEvents,
    required this.upcomingTasks,
  });
}

class HomeTaskItem {
  final String title;
  final String? timeLabel;
  final String priorityLabel;
  final String statusLabel;

  const HomeTaskItem({
    required this.title,
    required this.timeLabel,
    required this.priorityLabel,
    required this.statusLabel,
  });
}

class HomeEventItem {
  final String title;
  final String timeLabel;

  const HomeEventItem({
    required this.title,
    required this.timeLabel,
  });
}

class HomeController {
  final TaskRepository _taskRepository;
  final EventRepository _eventRepository;
  final JournalRepository _journalRepository;
  final NoteRepository _noteRepository;
  final MedicationRepository _medicationRepository;
  final MoodRepository _moodRepository;

  const HomeController({
    required TaskRepository taskRepository,
    required EventRepository eventRepository,
    required JournalRepository journalRepository,
    required NoteRepository noteRepository,
    required MedicationRepository medicationRepository,
    required MoodRepository moodRepository,
  })  : _taskRepository = taskRepository,
        _eventRepository = eventRepository,
        _journalRepository = journalRepository,
        _noteRepository = noteRepository,
        _medicationRepository = medicationRepository,
        _moodRepository = moodRepository;

  Future<HomeDashboardData> loadDashboard(GetDailyWater getDailyWater) async {
    final tasks = await _taskRepository.getAllTasks();
    final events = await _eventRepository.getAllEvents();
    final notes = await _noteRepository.getAllNotes();
    final journalEntries = await _journalRepository.getAllJournalEntries();
    final medications = await _medicationRepository.getActiveMedications();
    final moodEntries = await _moodRepository.getAllEntries();

    final now = DateTime.now();
    final todayStart = DateTime(now.year, now.month, now.day);
    final todayEnd = todayStart.add(const Duration(days: 1));

    final pendingTasks = tasks
        .where((task) => task.status != TaskStatus.completed)
        .toList()
      ..sort((a, b) {
        final aDue = a.dueDate ?? DateTime(2100);
        final bDue = b.dueDate ?? DateTime(2100);
        return aDue.compareTo(bDue);
      });

    final todayEvents = events
        .where((event) =>
            !event.startDateTime.isBefore(todayStart) && event.startDateTime.isBefore(todayEnd))
        .toList()
      ..sort((a, b) => a.startDateTime.compareTo(b.startDateTime));

    final sortedTasksByUpdate = [...tasks]
      ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    final latestTask = sortedTasksByUpdate.isNotEmpty ? sortedTasksByUpdate.first : null;

    final latestNote = notes.isNotEmpty ? notes.first : null;

    final sortedJournalEntries = [...journalEntries]
      ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    final latestJournalEntry =
        sortedJournalEntries.isNotEmpty ? sortedJournalEntries.first : null;

    final priorityTask = _pickPriorityTask(pendingTasks);

    final nextMedication = _findNextMedication(medications, now);
    final latestMoodEntry = moodEntries.isNotEmpty ? moodEntries.last : null;
    final yesterdayStart = todayStart.subtract(const Duration(days: 1));
    final journalUsedYesterday = journalEntries.any((entry) {
      return !entry.createdAt.isBefore(yesterdayStart) &&
          entry.createdAt.isBefore(todayStart);
    });

    final wellbeingSnapshot = await LocalJsonStore.readMap('wellbeing_state');
    final waterEntries = _waterEntriesFromSnapshot(wellbeingSnapshot);
    final medicationLogEntries = _medicationLogFromSnapshot(wellbeingSnapshot);
    final pomodoroSessions =
        (wellbeingSnapshot?['completedPomodoroSessions'] as int?) ?? 0;

    final nextMedicationTakenToday = nextMedication != null &&
      medicationLogEntries.any(
        (entry) =>
          entry.medicationId == nextMedication.id &&
          _isSameDay(entry.takenAt, now),
      );

    return HomeDashboardData(
      pendingTasksCount: pendingTasks.length,
      todayEventsCount: todayEvents.length,
      nextMedicationName: nextMedication?.name,
      nextMedicationDoseLabel: nextMedication == null
        ? null
        : '${nextMedication.dosage.amount.toStringAsFixed(nextMedication.dosage.amount % 1 == 0 ? 0 : 1)} ${nextMedication.dosage.unit.symbol}',
      nextMedicationTimeLabel: _nextMedicationTimeLabel(nextMedication, now),
      nextMedicationStatusLabel: nextMedication == null
        ? null
        : (nextMedicationTakenToday ? 'Tomado hoy' : 'Pendiente'),
      completedTasksCount: tasks.where((task) => task.status == TaskStatus.completed).length,
      waterConsumedMl: getDailyWater.call(waterEntries, now),
      moodLabel: _moodLabel(latestMoodEntry?.mood),
      energyLabel: latestJournalEntry == null
        ? null
        : '${latestJournalEntry.energy.toStringAsFixed(1)}/10',
      pomodoroSessions: pomodoroSessions,
      journalUsedYesterday: journalUsedYesterday,
      latestNoteLabel: _latestNoteLabel(latestNote?.title, latestNote?.content),
      latestTaskLabel: latestTask?.title,
      latestJournalLabel: latestJournalEntry?.firstLine,
      priorityTask: priorityTask == null
        ? null
        : HomeTaskItem(
          title: priorityTask.title,
          timeLabel: priorityTask.dueDate != null
            ? '${priorityTask.dueDate!.hour.toString().padLeft(2, '0')}:${priorityTask.dueDate!.minute.toString().padLeft(2, '0')}'
            : null,
          priorityLabel: priorityTask.priority.name,
          statusLabel: priorityTask.status.name,
        ),
      todayEvents: todayEvents
        .take(3)
        .map(
        (event) => HomeEventItem(
          title: event.title,
          timeLabel:
            '${event.startDateTime.hour.toString().padLeft(2, '0')}:${event.startDateTime.minute.toString().padLeft(2, '0')}',
        ),
        )
        .toList(),
      upcomingTasks: pendingTasks
          .take(5)
          .map(
            (task) => HomeTaskItem(
              title: task.title,
              timeLabel: task.dueDate != null
                  ? '${task.dueDate!.hour.toString().padLeft(2, '0')}:${task.dueDate!.minute.toString().padLeft(2, '0')}'
                  : null,
              priorityLabel: task.priority.name,
              statusLabel: task.status.name,
            ),
          )
          .toList(),
    );
  }

  String? _latestNoteLabel(String? title, String? content) {
    final cleanTitle = title?.trim() ?? '';
    if (cleanTitle.isNotEmpty) {
      return cleanTitle;
    }
    final cleanContent = content?.trim() ?? '';
    if (cleanContent.isEmpty) {
      return null;
    }
    return cleanContent.split('\n').first.trim();
  }

  DateTime? _parseScheduleTime(String raw, DateTime now) {
    final parts = raw.split(':');
    if (parts.length != 2) {
      return null;
    }
    final hour = int.tryParse(parts[0]);
    final minute = int.tryParse(parts[1]);
    if (hour == null || minute == null) {
      return null;
    }
    return DateTime(now.year, now.month, now.day, hour, minute);
  }

  String? _nextMedicationTimeLabel(Medication? medication, DateTime now) {
    if (medication == null || medication.schedule.isEmpty) {
      return null;
    }

    DateTime? candidate;
    for (final item in medication.schedule.whereType<String>()) {
      final parsedToday = _parseScheduleTime(item, now);
      if (parsedToday == null) {
        continue;
      }

      final parsed = parsedToday.isBefore(now)
          ? parsedToday.add(const Duration(days: 1))
          : parsedToday;
      if (candidate == null || parsed.isBefore(candidate)) {
        candidate = parsed;
      }
    }

    if (candidate == null) {
      return null;
    }
    return '${candidate.hour.toString().padLeft(2, '0')}:${candidate.minute.toString().padLeft(2, '0')}';
  }

  Medication? _findNextMedication(List<Medication> medications, DateTime now) {
    if (medications.isEmpty) {
      return null;
    }

    Medication? bestMedication;
    DateTime? bestDate;

    for (final medication in medications) {
      for (final item in medication.schedule.whereType<String>()) {
        final parsedToday = _parseScheduleTime(item, now);
        if (parsedToday == null) {
          continue;
        }

        final parsed = parsedToday.isBefore(now)
            ? parsedToday.add(const Duration(days: 1))
            : parsedToday;
        if (bestDate == null || parsed.isBefore(bestDate)) {
          bestDate = parsed;
          bestMedication = medication;
        }
      }
    }

    return bestMedication ?? medications.first;
  }

  Task? _pickPriorityTask(List<Task> pendingTasks) {
    if (pendingTasks.isEmpty) {
      return null;
    }

    final sorted = [...pendingTasks]..sort((Task a, Task b) {
      final byPriority = _priorityRank(b.priority).compareTo(_priorityRank(a.priority));
      if (byPriority != 0) {
        return byPriority;
      }
      final aDue = a.dueDate ?? DateTime(2100);
      final bDue = b.dueDate ?? DateTime(2100);
      return aDue.compareTo(bDue);
    });

    return sorted.first;
  }

  int _priorityRank(TaskPriority priority) {
    switch (priority) {
      case TaskPriority.critical:
        return 4;
      case TaskPriority.high:
        return 3;
      case TaskPriority.medium:
        return 2;
      case TaskPriority.low:
        return 1;
    }
  }

  List<_MedicationLogItem> _medicationLogFromSnapshot(
      Map<String, dynamic>? snapshot) {
    final raw = (snapshot?['medicationLog'] as List?) ?? const <dynamic>[];
    return raw.whereType<Map>().map((item) {
      final json = item.cast<String, dynamic>();
      return _MedicationLogItem(
        medicationId: (json['medicationId'] as String?) ?? '',
        takenAt: DateTime.tryParse((json['takenAt'] as String?) ?? '') ??
            DateTime.fromMillisecondsSinceEpoch(0),
      );
    }).toList(growable: false);
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  List<WaterEntry> _waterEntriesFromSnapshot(Map<String, dynamic>? snapshot) {
    final raw = (snapshot?['waterEntries'] as List?) ?? const <dynamic>[];
    return raw.whereType<Map>().map((item) {
      final json = item.cast<String, dynamic>();
      return WaterEntry(
        id: (json['id'] as String?) ?? DateTime.now().toIso8601String(),
        amountMl: (json['amountMl'] as int?) ?? 0,
        dateTime: DateTime.tryParse((json['dateTime'] as String?) ?? '') ??
            DateTime.now(),
      );
    }).toList(growable: false);
  }

  String _moodLabel(MoodType? moodType) {
    switch (moodType) {
      case MoodType.euphoric:
        return 'Eufórico';
      case MoodType.happy:
        return 'Feliz';
      case MoodType.neutral:
        return 'Estable';
      case MoodType.sad:
        return 'Bajón';
      case MoodType.depressed:
        return 'Cansado';
      case MoodType.anxious:
        return 'Ansioso';
      case MoodType.irritable:
        return 'Irritable';
      case MoodType.angry:
        return 'Enojado';
      default:
        return 'Sin registro';
    }
  }
}

final homeControllerProvider = Provider<HomeController>((ref) {
  return HomeController(
    taskRepository: ref.watch(taskRepositoryProvider),
    eventRepository: ref.watch(eventRepositoryProvider),
    journalRepository: ref.watch(journalRepositoryProvider),
    noteRepository: ref.watch(noteRepositoryProvider),
    medicationRepository: ref.watch(medicationRepositoryProvider),
    moodRepository: ref.watch(moodRepositoryProvider),
  );
});

final homeDashboardProvider = FutureProvider<HomeDashboardData>((ref) async {
  final controller = ref.watch(homeControllerProvider);
  final getDailyWater = ref.watch(getDailyWaterProvider);
  return controller.loadDashboard(getDailyWater);
});

class _MedicationLogItem {
  final String medicationId;
  final DateTime takenAt;

  const _MedicationLogItem({
    required this.medicationId,
    required this.takenAt,
  });
}
