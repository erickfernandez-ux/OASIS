import 'package:equatable/equatable.dart';

/// Defines how an entity repeats over time.
/// Used by Event, Task, Habit, and Reminder.
class RecurrenceRule extends Equatable {
  final RecurrenceFrequency frequency;
  final int interval;
  final List<int>? daysOfWeek;
  final DateTime? endDate;
  final int? maxOccurrences;

  const RecurrenceRule({
    required this.frequency,
    this.interval = 1,
    this.daysOfWeek,
    this.endDate,
    this.maxOccurrences,
  });

  /// Validates the recurrence rule.
  String? validate() {
    if (interval < 1) return 'Interval must be at least 1';
    if (daysOfWeek != null) {
      for (final day in daysOfWeek!) {
        if (day < 1 || day > 7) {
          return 'Days of week must be between 1 (Monday) and 7 (Sunday)';
        }
      }
    }
    return null;
  }

  bool get isValid => validate() == null;

  @override
  List<Object?> get props => [
        frequency,
        interval,
        daysOfWeek,
        endDate,
        maxOccurrences,
      ];

  @override
  String toString() =>
      'RecurrenceRule(frequency: $frequency, interval: $interval)';
}

/// Frequency options for recurrence.
enum RecurrenceFrequency {
  daily,
  weekly,
  monthly,
  yearly,
}
