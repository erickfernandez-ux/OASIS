import '../entities/habit.dart';
import '../enums/habit_frequency.dart';
import '../repositories/habit_repository.dart';

/// Creates a new habit with the given tracking configuration.
class CreateHabit {
  final HabitRepository _repository;

  const CreateHabit(this._repository);

  Future<Habit> call({
    required String title,
    required HabitFrequency frequency,
    required String goal,
    String? color,
  }) async {
    final habit = Habit(
      id: '',
      title: title,
      frequency: frequency,
      goal: goal,
      color: color,
      createdAt: DateTime.now(),
    );
    return _repository.createHabit(habit);
  }
}
