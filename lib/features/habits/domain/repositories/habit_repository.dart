import '../entities/habit.dart';

/// Contract for Habit data operations.
abstract class HabitRepository {
  /// Returns all habits.
  Future<List<Habit>> getAllHabits();

  /// Returns a single habit by id, or null if not found.
  Future<Habit?> getHabitById(String id);

  /// Persists a new habit.
  Future<Habit> createHabit(Habit habit);

  /// Updates an existing habit.
  Future<Habit> updateHabit(Habit habit);

  /// Deletes a habit by id.
  Future<bool> deleteHabit(String id);

  /// Records a completion for today.
  Future<Habit> recordCompletion(String id, DateTime date);
}
