import 'package:flutter_riverpod/flutter_riverpod.dart';

enum AppLaunchIntent {
  openCalendarNewEvent,
  openAgendaCalendarNewEvent,
  openAgendaTasksNewTask,
  openNotesNewNote,
}

final appLaunchIntentProvider = StateProvider<AppLaunchIntent?>((ref) => null);
