import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/di/usecase_providers.dart';
import '../../domain/entities/habit.dart';
import '../../domain/enums/habit_frequency.dart';

/// Controls the state and operations of the Habits feature.
class HabitsController extends AsyncNotifier<List<Habit>> {
  @override
  Future<List<Habit>> build() async {
    return _fetchHabits();
  }

  Future<List<Habit>> _fetchHabits() async {
    final getHabits = ref.read(getHabitsProvider);
    return getHabits();
  }

  /// Creates a new habit.
  Future<void> createHabit({
    required String title,
    required HabitFrequency frequency,
    required String goal,
    String? color,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final createHabit = ref.read(createHabitProvider);
      await createHabit(
        title: title,
        frequency: frequency,
        goal: goal,
        color: color,
      );
      return _fetchHabits();
    });
  }

  /// Records a habit completion for today.
  Future<void> completeHabit(String id) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final completeHabit = ref.read(completeHabitProvider);
      await completeHabit(id);
      return _fetchHabits();
    });
  }

  /// Deletes a habit.
  Future<void> deleteHabit(String id) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final deleteHabit = ref.read(deleteHabitProvider);
      await deleteHabit(id);
      return _fetchHabits();
    });
  }

  /// Refreshes the habits list.
  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(_fetchHabits);
  }
}

final habitsControllerProvider =
    AsyncNotifierProvider<HabitsController, List<Habit>>(() {
  return HabitsController();
});
