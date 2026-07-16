import '../entities/habit.dart';
import '../repositories/habit_repository.dart';

/// Updates an existing habit's configuration.
class UpdateHabit {
  final HabitRepository _repository;

  const UpdateHabit(this._repository);

  Future<Habit> call(Habit habit) async {
    return _repository.updateHabit(habit);
  }
}
