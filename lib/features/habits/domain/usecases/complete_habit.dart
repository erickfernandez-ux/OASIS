import '../entities/habit.dart';
import '../repositories/habit_repository.dart';

/// Records a completion for a habit on the given date.
/// Updates streak counters accordingly.
class CompleteHabit {
  final HabitRepository _repository;

  const CompleteHabit(this._repository);

  Future<Habit> call(String id, {DateTime? date}) async {
    return _repository.recordCompletion(id, date ?? DateTime.now());
  }
}
