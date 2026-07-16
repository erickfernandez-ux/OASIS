import '../entities/task.dart';
import '../repositories/task_repository.dart';

/// Retrieves all tasks ordered by creation date.
class GetAllTasks {
  final TaskRepository _repository;

  const GetAllTasks(this._repository);

  Future<List<Task>> call() async {
    return _repository.getAllTasks();
  }
}
