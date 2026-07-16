import '../entities/task.dart';
import '../repositories/task_repository.dart';

/// Retrieves a single task by its unique identifier.
/// Returns null if the task does not exist.
class GetTask {
  final TaskRepository _repository;

  const GetTask(this._repository);

  Future<Task?> call(String id) async {
    return _repository.getTaskById(id);
  }
}
