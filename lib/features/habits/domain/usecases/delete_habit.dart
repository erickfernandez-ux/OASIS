import '../repositories/habit_repository.dart';

/// Permanently removes a habit and its tracking history.
class DeleteHabit {
  final HabitRepository _repository;

  const DeleteHabit(this._repository);

  Future<bool> call(String id) async {
    return _repository.deleteHabit(id);
  }
}
