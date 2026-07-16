import 'package:equatable/equatable.dart';

import '../enums/task_priority.dart';
import '../enums/task_status.dart';

/// Represents a concrete action the user must perform.
/// Tasks are the atomic unit of commitment in OASIS.
class Task extends Equatable {
  final String id;
  final String title;
  final String? description;
  final TaskStatus status;
  final TaskPriority priority;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? dueDate;
  final DateTime? completedAt;
  final List<String> tags;

  const Task({
    required this.id,
    required this.title,
    this.description,
    this.status = TaskStatus.pending,
    this.priority = TaskPriority.medium,
    required this.createdAt,
    required this.updatedAt,
    this.dueDate,
    this.completedAt,
    this.tags = const [],
  });

  Task copyWith({
    String? id,
    String? title,
    String? description,
    TaskStatus? status,
    TaskPriority? priority,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? dueDate,
    DateTime? completedAt,
    List<String>? tags,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      status: status ?? this.status,
      priority: priority ?? this.priority,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      dueDate: dueDate ?? this.dueDate,
      completedAt: completedAt ?? this.completedAt,
      tags: tags ?? this.tags,
    );
  }

  @override
  List<Object?> get props => [
        id,
        title,
        description,
        status,
        priority,
        createdAt,
        updatedAt,
        dueDate,
        completedAt,
        tags,
      ];

  @override
  String toString() => 'Task(id: $id, title: $title, status: $status)';
}
