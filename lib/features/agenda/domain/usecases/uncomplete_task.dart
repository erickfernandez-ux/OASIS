import '../entities/task.dart';
import '../enums/task_status.dart';
import '../repositories/task_repository.dart';

/// Reverts a completed task back to pending status.
/// Removes the completion timestamp.
class UncompleteTask {
  final TaskRepository _repository;

  const UncompleteTask(this._repository);

  Future<Task> call(String id) async {
    final task = await _repository.getTaskById(id);
    if (task == null) throw Exception('Task not found');

    final reverted = task.copyWith(
      status: TaskStatus.pending,
      completedAt: null,
    );
    return _repository.updateTask(reverted);
  }
}
