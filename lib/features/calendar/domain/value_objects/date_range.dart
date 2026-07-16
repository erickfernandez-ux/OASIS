import 'package:equatable/equatable.dart';

/// Represents an immutable date range with validation.
/// Ensures that the end date is always after the start date.
class DateRange extends Equatable {
  final DateTime start;
  final DateTime end;
  final bool isAllDay;

  const DateRange({
    required this.start,
    required this.end,
    this.isAllDay = false,
  });

  /// Validates that the range is coherent.
  String? validate() {
    if (end.isBefore(start)) {
      return 'End date must be after start date';
    }
    return null;
  }

  bool get isValid => validate() == null;

  /// Returns the duration of the range.
  Duration get duration => end.difference(start);

  /// Returns true if the given dateTime falls within this range.
  bool contains(DateTime dateTime) {
    return dateTime.isAfter(start) && dateTime.isBefore(end) ||
        dateTime.isAtSameMomentAs(start) ||
        dateTime.isAtSameMomentAs(end);
  }

  /// Returns true if this range overlaps with another.
  bool overlaps(DateRange other) {
    return start.isBefore(other.end) && end.isAfter(other.start);
  }

  @override
  List<Object?> get props => [start, end, isAllDay];

  @override
  String toString() => 'DateRange($start → $end, allDay: $isAllDay)';
}
