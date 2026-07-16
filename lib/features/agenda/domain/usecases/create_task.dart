import '../entities/task.dart';
import '../enums/task_status.dart';
import '../repositories/task_repository.dart';

/// Creates a new task with default status [pending].
/// The repository assigns the generated id.
class CreateTask {
  final TaskRepository _repository;

  const CreateTask(this._repository);

  /// Executes the use case.
  /// [title] is required. All other fields are optional.
  Future<Task> call({
    required String title,
    String? description,
    DateTime? dueDate,
  }) async {
    final now = DateTime.now();
    final task = Task(
      id: '',
      title: title,
      description: description,
      status: TaskStatus.pending,
      dueDate: dueDate,
      createdAt: now,
      updatedAt: now,
    );
    return _repository.createTask(task);
  }
}
