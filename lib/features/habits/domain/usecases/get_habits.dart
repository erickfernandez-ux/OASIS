import '../entities/habit.dart';
import '../repositories/habit_repository.dart';

/// Retrieves all habits ordered by creation date.
class GetHabits {
  final HabitRepository _repository;

  const GetHabits(this._repository);

  Future<List<Habit>> call() async {
    return _repository.getAllHabits();
  }
}
