import '../entities/task.dart';
import '../repositories/task_repository.dart';

/// Updates an existing task identified by [id].
/// Only provided fields are modified; others remain unchanged.
class UpdateTask {
  final TaskRepository _repository;

  const UpdateTask(this._repository);

  Future<Task> call(Task task) async {
    return _repository.updateTask(task);
  }
}
