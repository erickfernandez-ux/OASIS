import 'package:equatable/equatable.dart';

import '../enums/habit_frequency.dart';

/// Represents a recurring behavior pattern aimed at automation.
/// Unlike a Task, a Habit never "ends" — it is a continuous pattern.
class Habit extends Equatable {
  final String id;
  final String title;
  final HabitFrequency frequency;
  final String goal;
  final String? color;
  final DateTime createdAt;

  const Habit({
    required this.id,
    required this.title,
    required this.frequency,
    required this.goal,
    this.color,
    required this.createdAt,
  });

  Habit copyWith({
    String? id,
    String? title,
    HabitFrequency? frequency,
    String? goal,
    String? color,
    DateTime? createdAt,
  }) {
    return Habit(
      id: id ?? this.id,
      title: title ?? this.title,
      frequency: frequency ?? this.frequency,
      goal: goal ?? this.goal,
      color: color ?? this.color,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props => [id, title, frequency, goal, color, createdAt];

  @override
  String toString() => 'Habit(id: $id, title: $title, frequency: $frequency)';
}
