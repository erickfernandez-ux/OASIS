import '../entities/task.dart';

/// Contract for Task data operations.
/// Implementations will handle Supabase, local cache, or mock data.
abstract class TaskRepository {
  /// Returns all tasks ordered by creation date.
  Future<List<Task>> getAllTasks();

  /// Returns a single task by id, or null if not found.
  Future<Task?> getTaskById(String id);

  /// Returns tasks filtered by status.
  Future<List<Task>> getTasksByStatus(String status);

  /// Returns tasks due on or before the given date.
  Future<List<Task>> getTasksDueBefore(DateTime date);

  /// Persists a new task. Returns the created task with generated id.
  Future<Task> createTask(Task task);

  /// Updates an existing task. Returns the updated task.
  Future<Task> updateTask(Task task);

  /// Deletes a task by id. Returns true if deleted.
  Future<bool> deleteTask(String id);

  /// Returns tasks matching the given tag.
  Future<List<Task>> getTasksByTag(String tag);
}
