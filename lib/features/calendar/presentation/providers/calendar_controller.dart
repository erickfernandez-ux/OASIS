import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/di/usecase_providers.dart';
import '../../../agenda/domain/entities/task.dart';
import '../../../agenda/domain/enums/task_status.dart';
import '../../../medications/domain/entities/medication.dart';
import '../../domain/entities/event.dart';

enum CalendarView { dayAgenda, monthView }

class CalendarTimelineItem {
  final String id;
  final String title;
  final String subtitle;
  final DateTime time;
  final String kind;
  final String? color;
  final bool isCompleted;

  const CalendarTimelineItem({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.time,
    required this.kind,
    this.color,
    this.isCompleted = false,
  });
}

class CalendarState {
  final List<Event> events;
  final List<Task> tasks;
  final List<Medication> medications;
  final DateTime selectedDay;
  final CalendarView viewMode;

  const CalendarState({
    required this.events,
    required this.tasks,
    required this.medications,
    required this.selectedDay,
    required this.viewMode,
  });

  CalendarState copyWith({
    List<Event>? events,
    List<Task>? tasks,
    List<Medication>? medications,
    DateTime? selectedDay,
    CalendarView? viewMode,
  }) {
    return CalendarState(
      events: events ?? this.events,
      tasks: tasks ?? this.tasks,
      medications: medications ?? this.medications,
      selectedDay: selectedDay ?? this.selectedDay,
      viewMode: viewMode ?? this.viewMode,
    );
  }

  List<CalendarTimelineItem> timelineItemsForSelectedDay() {
    final items = <CalendarTimelineItem>[];
    final selectedDate = DateUtils.dateOnly(selectedDay);

    for (final event
        in events.where((item) => _sameDay(item.startDateTime, selectedDate))) {
      items.add(
        CalendarTimelineItem(
          id: 'event-${event.id}',
          title: event.title,
          subtitle: event.description ?? 'Evento',
          time: event.startDateTime,
          kind: 'event',
          color: event.color,
        ),
      );
    }

    for (final task in tasks.where((item) =>
        item.dueDate != null && _sameDay(item.dueDate!, selectedDate))) {
      items.add(
        CalendarTimelineItem(
          id: 'task-${task.id}',
          title: task.title,
          subtitle: task.description ?? 'Tarea',
          time: task.dueDate!,
          kind: 'task',
          isCompleted: task.status == TaskStatus.completed,
        ),
      );
    }

    for (final medication in medications) {
      for (final schedule in medication.schedule) {
        final time = _parseScheduleTime(schedule, selectedDate);
        if (time != null) {
          items.add(
            CalendarTimelineItem(
              id: 'med-${medication.id}-$schedule',
              title: medication.name,
              subtitle: medication.instructions ?? medication.dosage.toString(),
              time: time,
              kind: 'medication',
            ),
          );
        }
      }
    }

    items.sort((a, b) => a.time.compareTo(b.time));
    return items;
  }

  Set<DateTime> daysWithContent() {
    final dates = <DateTime>{};
    for (final event in events) {
      dates.add(DateUtils.dateOnly(event.startDateTime));
    }
    for (final task in tasks.where((item) => item.dueDate != null)) {
      dates.add(DateUtils.dateOnly(task.dueDate!));
    }
    for (final medication in medications) {
      for (final schedule in medication.schedule) {
        final parsed =
            _parseScheduleTime(schedule, DateUtils.dateOnly(DateTime.now()));
        if (parsed != null) {
          dates.add(DateUtils.dateOnly(parsed));
        }
      }
    }
    return dates;
  }

  bool _sameDay(DateTime first, DateTime second) {
    return DateUtils.dateOnly(first)
        .isAtSameMomentAs(DateUtils.dateOnly(second));
  }

  DateTime? _parseScheduleTime(String schedule, DateTime day) {
    final parts = schedule.split(':');
    if (parts.length != 2) return null;
    final hour = int.tryParse(parts[0]);
    final minute = int.tryParse(parts[1]);
    if (hour == null || minute == null) return null;
    return DateTime(day.year, day.month, day.day, hour, minute);
  }
}

class CalendarController extends AsyncNotifier<CalendarState> {
  DateTime _selectedDay = DateUtils.dateOnly(DateTime.now());
  CalendarView _viewMode = CalendarView.dayAgenda;

  @override
  Future<CalendarState> build() async {
    return _loadState();
  }

  Future<CalendarState> _loadState() async {
    final getEvents = ref.read(getEventsProvider);
    final getAllTasks = ref.read(getAllTasksProvider);
    final getAllMedications = ref.read(getMedicationsProvider);

    final events = await getEvents();
    final tasks = await getAllTasks();
    final medications = await getAllMedications();

    return CalendarState(
      events: events,
      tasks: tasks,
      medications: medications,
      selectedDay: _selectedDay,
      viewMode: _viewMode,
    );
  }

  Future<void> createEvent({
    required String title,
    required DateTime startDateTime,
    required DateTime endDateTime,
    String? description,
    String? location,
    String? color,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final createEvent = ref.read(createEventProvider);
      final created = await createEvent(
        title: title,
        startDateTime: startDateTime,
        endDateTime: endDateTime,
        description: description,
        location: location,
        color: color,
      );
      _prepareEventNotificationDraft(created);
      return _loadState();
    });
  }

  Future<void> updateEvent({
    required String id,
    String? title,
    String? description,
    DateTime? startDateTime,
    DateTime? endDateTime,
    String? location,
    String? color,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final current = (await ref.read(getEventsProvider)())
          .firstWhere((event) => event.id == id);
      final updated = current.copyWith(
        title: title ?? current.title,
        description: description ?? current.description,
        startDateTime: startDateTime ?? current.startDateTime,
        endDateTime: endDateTime ?? current.endDateTime,
        location: location ?? current.location,
        color: color ?? current.color,
      );
      final updateEvent = ref.read(updateEventProvider);
      final updatedEvent = await updateEvent(updated);
      _prepareEventNotificationDraft(updatedEvent);
      return _loadState();
    });
  }

  void _prepareEventNotificationDraft(Event event) {
    // Placeholder hook for future notification orchestration.
    // This intentionally does not schedule notifications yet.
    final _ = event;
  }

  Future<void> deleteEvent(String id) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final deleteEvent = ref.read(deleteEventProvider);
      await deleteEvent(id);
      return _loadState();
    });
  }

  Future<void> setSelectedDay(DateTime day) async {
    _selectedDay = DateUtils.dateOnly(day);
    state = await AsyncValue.guard(_loadState);
  }

  Future<void> setViewMode(CalendarView viewMode) async {
    _viewMode = viewMode;
    state = await AsyncValue.guard(_loadState);
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(_loadState);
  }
}

final calendarControllerProvider =
    AsyncNotifierProvider<CalendarController, CalendarState>(() {
  return CalendarController();
});
