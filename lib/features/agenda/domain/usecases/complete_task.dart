import '../entities/task.dart';
import '../enums/task_status.dart';
import '../repositories/task_repository.dart';

/// Marks a task as completed and records the completion timestamp.
class CompleteTask {
  final TaskRepository _repository;

  const CompleteTask(this._repository);

  Future<Task> call(String id) async {
    final task = await _repository.getTaskById(id);
    if (task == null) throw Exception('Task not found');

    final completed = task.copyWith(
      status: TaskStatus.completed,
      completedAt: DateTime.now(),
    );
    return _repository.updateTask(completed);
  }
}
