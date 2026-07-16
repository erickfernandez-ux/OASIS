import 'package:uuid/uuid.dart';

import '../../../../core/utils/local_json_store.dart';

import '../../domain/entities/task.dart';
import '../../domain/enums/task_priority.dart';
import '../../domain/enums/task_status.dart';
import '../../domain/repositories/task_repository.dart';

/// In-memory implementation of [TaskRepository].
class MockTaskRepository implements TaskRepository {
  static const _storageKey = 'tasks';
  final List<Task> _tasks = [];
  final _uuid = const Uuid();
  Future<void>? _initFuture;

  MockTaskRepository() {
    _seedData();
  }

  void _seedData() {
    final now = DateTime.now();
    _tasks.addAll([
      Task(
        id: 'sample-task-review-emails',
        title: 'Revisar correos pendientes',
        description: 'Responder a los correos acumulados de la semana',
        status: TaskStatus.pending,
        priority: TaskPriority.high,
        dueDate: now.add(const Duration(days: 1)),
        createdAt: now.subtract(const Duration(days: 2)),
        updatedAt: now.subtract(const Duration(days: 2)),
        tags: const ['trabajo', 'administrativo', 'ejemplo'],
      ),
      Task(
        id: 'sample-task-call-dentist',
        title: 'Llamar al dentista',
        description: 'Pedir cita para revisión anual',
        status: TaskStatus.pending,
        priority: TaskPriority.medium,
        dueDate: now.add(const Duration(days: 7)),
        createdAt: now.subtract(const Duration(days: 1)),
        updatedAt: now.subtract(const Duration(days: 1)),
        tags: const ['salud', 'personal', 'ejemplo'],
      ),
      Task(
        id: 'sample-task-dinner-ingredients',
        title: 'Comprar ingredientes para la cena',
        description: 'Pollo, verduras, arroz',
        status: TaskStatus.completed,
        priority: TaskPriority.low,
        dueDate: now.subtract(const Duration(days: 1)),
        createdAt: now.subtract(const Duration(days: 3)),
        updatedAt: now.subtract(const Duration(days: 3)),
        completedAt: now.subtract(const Duration(hours: 5)),
        tags: const ['hogar', 'ejemplo'],
      ),
    ]);
  }

  @override
  Future<List<Task>> getAllTasks() async {
    await _ensureInitialized();
    await _simulateNetworkDelay();
    return List.unmodifiable(_tasks..sort((a, b) => b.createdAt.compareTo(a.createdAt)));
  }

  @override
  Future<Task?> getTaskById(String id) async {
    await _ensureInitialized();
    await _simulateNetworkDelay();
    try {
      return _tasks.firstWhere((t) => t.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<List<Task>> getTasksByStatus(String status) async {
    await _ensureInitialized();
    await _simulateNetworkDelay();
    return _tasks.where((t) => t.status.name == status).toList();
  }

  @override
  Future<List<Task>> getTasksDueBefore(DateTime date) async {
    await _ensureInitialized();
    await _simulateNetworkDelay();
    return _tasks.where((t) => t.dueDate != null && !t.dueDate!.isAfter(date)).toList();
  }

  @override
  Future<Task> createTask(Task task) async {
    await _ensureInitialized();
    await _simulateNetworkDelay();
    final created = task.copyWith(id: task.id.isEmpty ? _uuid.v4() : task.id);
    _tasks.add(created);
    await _persist();
    return created;
  }

  @override
  Future<Task> updateTask(Task task) async {
    await _ensureInitialized();
    await _simulateNetworkDelay();
    final index = _tasks.indexWhere((t) => t.id == task.id);
    if (index == -1) throw Exception('Task not found: ${task.id}');
    _tasks[index] = task.copyWith(updatedAt: DateTime.now());
    await _persist();
    return _tasks[index];
  }

  @override
  Future<bool> deleteTask(String id) async {
    await _ensureInitialized();
    await _simulateNetworkDelay();
    final index = _tasks.indexWhere((t) => t.id == id);
    if (index == -1) return false;
    _tasks.removeAt(index);
    await _persist();
    return true;
  }

  @override
  Future<List<Task>> getTasksByTag(String tag) async {
    await _ensureInitialized();
    await _simulateNetworkDelay();
    return _tasks.where((t) => t.tags.contains(tag)).toList();
  }

  Future<void> _ensureInitialized() {
    _initFuture ??= _loadFromStorage();
    return _initFuture!;
  }

  Future<void> _loadFromStorage() async {
    final raw = await LocalJsonStore.readList(_storageKey);
    if (raw == null) {
      return;
    }
    if (raw.isEmpty) {
      _tasks.clear();
      return;
    }

    _tasks
      ..clear()
      ..addAll(
        raw
            .whereType<Map>()
            .map((item) => _fromJson(item.cast<String, dynamic>())),
      );
  }

  Future<void> _persist() async {
    await LocalJsonStore.writeList(
      _storageKey,
      _tasks.map(_toJson).toList(growable: false),
    );
  }

  Map<String, dynamic> _toJson(Task task) {
    return {
      'id': task.id,
      'title': task.title,
      'description': task.description,
      'status': task.status.name,
      'priority': task.priority.name,
      'createdAt': task.createdAt.toIso8601String(),
      'updatedAt': task.updatedAt.toIso8601String(),
      'dueDate': task.dueDate?.toIso8601String(),
      'completedAt': task.completedAt?.toIso8601String(),
      'tags': task.tags,
    };
  }

  Task _fromJson(Map<String, dynamic> json) {
    return Task(
      id: (json['id'] as String?) ?? _uuid.v4(),
      title: (json['title'] as String?) ?? 'Tarea',
      description: json['description'] as String?,
      status: TaskStatus.values.firstWhere(
        (item) => item.name == json['status'],
        orElse: () => TaskStatus.pending,
      ),
      priority: TaskPriority.values.firstWhere(
        (item) => item.name == json['priority'],
        orElse: () => TaskPriority.medium,
      ),
      createdAt: DateTime.tryParse((json['createdAt'] as String?) ?? '') ??
          DateTime.now(),
      updatedAt: DateTime.tryParse((json['updatedAt'] as String?) ?? '') ??
          DateTime.now(),
      dueDate: DateTime.tryParse((json['dueDate'] as String?) ?? ''),
      completedAt: DateTime.tryParse((json['completedAt'] as String?) ?? ''),
      tags:
          (json['tags'] as List?)?.whereType<String>().toList(growable: false) ??
              const <String>[],
    );
  }

  Future<void> _simulateNetworkDelay() async {
    await Future.delayed(const Duration(milliseconds: 150));
  }
}
