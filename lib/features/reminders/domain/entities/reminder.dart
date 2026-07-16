import 'package:equatable/equatable.dart';

import '../enums/reminder_repeat.dart';

/// Represents a designed interruption to bring something to consciousness.
/// A Reminder always belongs to another entity; it does not exist independently.
class Reminder extends Equatable {
  final String id;
  final String title;
  final DateTime dateTime;
  final ReminderRepeat repeatRule;
  final bool isCompleted;

  const Reminder({
    required this.id,
    required this.title,
    required this.dateTime,
    this.repeatRule = ReminderRepeat.once,
    this.isCompleted = false,
  });

  Reminder copyWith({
    String? id,
    String? title,
    DateTime? dateTime,
    ReminderRepeat? repeatRule,
    bool? isCompleted,
  }) {
    return Reminder(
      id: id ?? this.id,
      title: title ?? this.title,
      dateTime: dateTime ?? this.dateTime,
      repeatRule: repeatRule ?? this.repeatRule,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }

  @override
  List<Object?> get props => [id, title, dateTime, repeatRule, isCompleted];

  @override
  String toString() => 'Reminder(id: $id, title: $title, trigger: $dateTime)';
}
