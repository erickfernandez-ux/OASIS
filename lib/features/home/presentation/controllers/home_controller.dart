import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/di/di.dart';
import '../../../../core/utils/local_json_store.dart';
import '../../../agenda/domain/enums/task_status.dart';
import '../../../agenda/domain/repositories/task_repository.dart';
import '../../../calendar/domain/repositories/event_repository.dart';
import '../../../journal/domain/repositories/journal_repository.dart';
import '../../../medications/domain/repositories/medication_repository.dart';
import '../../../wellbeing/domain/entities/water_entry.dart';
import '../../../wellbeing/domain/enums/mood_type.dart';
import '../../../wellbeing/domain/repositories/mood_repository.dart';
import '../../../wellbeing/domain/usecases/get_daily_water.dart';

class HomeDashboardData {
  final int pendingTasksCount;
  final int todayEventsCount;
  final String nextMedicationLabel;
  final int completedTasksCount;
  final int waterConsumedMl;
  final String moodLabel;
  final int pomodoroSessions;
  final bool journalUsedYesterday;
  final List<HomeTaskItem> upcomingTasks;

  const HomeDashboardData({
    required this.pendingTasksCount,
    required this.todayEventsCount,
    required this.nextMedicationLabel,
    required this.completedTasksCount,
    required this.waterConsumedMl,
    required this.moodLabel,
    required this.pomodoroSessions,
    required this.journalUsedYesterday,
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

class HomeController {
  final TaskRepository _taskRepository;
  final EventRepository _eventRepository;
  final JournalRepository _journalRepository;
  final MedicationRepository _medicationRepository;
  final MoodRepository _moodRepository;

  const HomeController({
    required TaskRepository taskRepository,
    required EventRepository eventRepository,
    required JournalRepository journalRepository,
    required MedicationRepository medicationRepository,
    required MoodRepository moodRepository,
  })  : _taskRepository = taskRepository,
        _eventRepository = eventRepository,
      _journalRepository = journalRepository,
        _medicationRepository = medicationRepository,
        _moodRepository = moodRepository;

  Future<HomeDashboardData> loadDashboard(GetDailyWater getDailyWater) async {
    final tasks = await _taskRepository.getAllTasks();
    final events = await _eventRepository.getAllEvents();
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

    final nextMedication = medications.isNotEmpty ? medications.first : null;
    final latestMoodEntry = moodEntries.isNotEmpty ? moodEntries.last : null;
    final yesterdayStart = todayStart.subtract(const Duration(days: 1));
    final journalUsedYesterday = journalEntries.any((entry) {
      return !entry.createdAt.isBefore(yesterdayStart) &&
          entry.createdAt.isBefore(todayStart);
    });

    final wellbeingSnapshot = await LocalJsonStore.readMap('wellbeing_state');
    final waterEntries = _waterEntriesFromSnapshot(wellbeingSnapshot);
    final pomodoroSessions =
        (wellbeingSnapshot?['completedPomodoroSessions'] as int?) ?? 0;

    return HomeDashboardData(
      pendingTasksCount: pendingTasks.length,
      todayEventsCount: todayEvents.length,
      nextMedicationLabel: nextMedication?.name ?? 'Sin medicamentos próximos',
      completedTasksCount: tasks.where((task) => task.status == TaskStatus.completed).length,
      waterConsumedMl: getDailyWater.call(waterEntries, now),
      moodLabel: _moodLabel(latestMoodEntry?.mood),
      pomodoroSessions: pomodoroSessions,
      journalUsedYesterday: journalUsedYesterday,
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
    medicationRepository: ref.watch(medicationRepositoryProvider),
    moodRepository: ref.watch(moodRepositoryProvider),
  );
});

final homeDashboardProvider = FutureProvider<HomeDashboardData>((ref) async {
  final controller = ref.watch(homeControllerProvider);
  final getDailyWater = ref.watch(getDailyWaterProvider);
  return controller.loadDashboard(getDailyWater);
});
