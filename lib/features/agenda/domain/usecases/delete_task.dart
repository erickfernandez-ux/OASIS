import '../repositories/task_repository.dart';

/// Permanently removes a task from the system.
class DeleteTask {
  final TaskRepository _repository;

  const DeleteTask(this._repository);

  Future<bool> call(String id) async {
    return _repository.deleteTask(id);
  }
}
