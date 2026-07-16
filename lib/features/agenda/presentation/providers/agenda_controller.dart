import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/di/usecase_providers.dart';
import '../../domain/entities/task.dart';
import '../../domain/enums/task_priority.dart';
import '../../domain/enums/task_status.dart';

enum TaskFilter { all, pending, completed }

class AgendaController extends AsyncNotifier<List<Task>> {
  TaskFilter _filter = TaskFilter.all;
  String _searchQuery = '';

  @override
  Future<List<Task>> build() async {
    return _fetchTasks();
  }

  Future<List<Task>> _fetchTasks() async {
    final getAllTasks = ref.read(getAllTasksProvider);
    final tasks = await getAllTasks();
    return _applyFilters(tasks);
  }

  Future<void> createTask({
    required String title,
    String? description,
    DateTime? dueDate,
    TaskPriority priority = TaskPriority.medium,
    List<String>? tags,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final createTask = ref.read(createTaskProvider);
      final created = await createTask(
        title: title,
        description: description,
        dueDate: dueDate,
      );
      if (priority != created.priority || (tags != null && tags.isNotEmpty)) {
        final updated = created.copyWith(
          priority: priority,
          tags: tags ?? created.tags,
        );
        final updateTask = ref.read(updateTaskProvider);
        await updateTask(updated);
      }
      return _fetchTasks();
    });
  }

  Future<void> updateTask({
    required String id,
    String? title,
    String? description,
    DateTime? dueDate,
    TaskPriority? priority,
    TaskStatus? status,
    List<String>? tags,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final tasks = await ref.read(getAllTasksProvider)();
      final current = tasks.firstWhere((task) => task.id == id);
      final updated = current.copyWith(
        title: title ?? current.title,
        description: description ?? current.description,
        dueDate: dueDate ?? current.dueDate,
        priority: priority ?? current.priority,
        status: status ?? current.status,
        tags: tags ?? current.tags,
      );
      final updateTask = ref.read(updateTaskProvider);
      await updateTask(updated);
      return _fetchTasks();
    });
  }

  Future<void> completeTask(String id) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final completeTask = ref.read(completeTaskProvider);
      await completeTask(id);
      return _fetchTasks();
    });
  }

  Future<void> uncompleteTask(String id) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final uncompleteTask = ref.read(uncompleteTaskProvider);
      await uncompleteTask(id);
      return _fetchTasks();
    });
  }

  Future<void> deleteTask(String id) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final deleteTask = ref.read(deleteTaskProvider);
      await deleteTask(id);
      return _fetchTasks();
    });
  }

  Future<void> setFilter(TaskFilter filter) async {
    _filter = filter;
    state = await AsyncValue.guard(_fetchTasks);
  }

  Future<void> setSearchQuery(String query) async {
    _searchQuery = query.trim().toLowerCase();
    state = await AsyncValue.guard(_fetchTasks);
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(_fetchTasks);
  }

  List<Task> _applyFilters(List<Task> tasks) {
    var filtered = tasks.where((task) {
      final matchesSearch = _searchQuery.isEmpty ||
          task.title.toLowerCase().contains(_searchQuery) ||
          (task.description?.toLowerCase().contains(_searchQuery) ?? false);
      return matchesSearch;
    }).toList();

    switch (_filter) {
      case TaskFilter.pending:
        filtered = filtered.where((task) => task.status != TaskStatus.completed).toList();
        break;
      case TaskFilter.completed:
        filtered = filtered.where((task) => task.status == TaskStatus.completed).toList();
        break;
      case TaskFilter.all:
        break;
    }

    return filtered;
  }
}

final agendaControllerProvider = AsyncNotifierProvider<AgendaController, List<Task>>(() {
  return AgendaController();
});
