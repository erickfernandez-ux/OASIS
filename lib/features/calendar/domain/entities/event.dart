import 'package:equatable/equatable.dart';

import '../enums/event_type.dart';

/// Represents a fixed temporal commitment.
/// Unlike a Task, an Event occupies time on the calendar.
class Event extends Equatable {
  final String id;
  final String title;
  final String? description;
  final DateTime startDateTime;
  final DateTime endDateTime;
  final bool allDay;
  final String? location;
  final EventType type;
  final String? color;
  final bool isRecurring;
  final String? recurrenceRuleId;
  final Duration? bufferBefore;
  final Duration? bufferAfter;
  final Duration? travelTime;
  final List<Duration> alertOffsets;
  final DateTime createdAt;

  const Event({
    required this.id,
    required this.title,
    this.description,
    required this.startDateTime,
    required this.endDateTime,
    this.allDay = false,
    this.location,
    this.type = EventType.personal,
    this.color,
    this.isRecurring = false,
    this.recurrenceRuleId,
    this.bufferBefore,
    this.bufferAfter,
    this.travelTime,
    this.alertOffsets = const [],
    required this.createdAt,
  });

  Event copyWith({
    String? id,
    String? title,
    String? description,
    DateTime? startDateTime,
    DateTime? endDateTime,
    bool? allDay,
    String? location,
    EventType? type,
    String? color,
    bool? isRecurring,
    String? recurrenceRuleId,
    Duration? bufferBefore,
    Duration? bufferAfter,
    Duration? travelTime,
    List<Duration>? alertOffsets,
    DateTime? createdAt,
  }) {
    return Event(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      startDateTime: startDateTime ?? this.startDateTime,
      endDateTime: endDateTime ?? this.endDateTime,
      allDay: allDay ?? this.allDay,
      location: location ?? this.location,
      type: type ?? this.type,
      color: color ?? this.color,
      isRecurring: isRecurring ?? this.isRecurring,
      recurrenceRuleId: recurrenceRuleId ?? this.recurrenceRuleId,
      bufferBefore: bufferBefore ?? this.bufferBefore,
      bufferAfter: bufferAfter ?? this.bufferAfter,
      travelTime: travelTime ?? this.travelTime,
      alertOffsets: alertOffsets ?? this.alertOffsets,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        title,
        description,
        startDateTime,
        endDateTime,
        allDay,
        location,
        type,
        color,
        isRecurring,
        recurrenceRuleId,
        bufferBefore,
        bufferAfter,
        travelTime,
        alertOffsets,
        createdAt,
      ];

  @override
  String toString() => 'Event(id: $id, title: $title, start: $startDateTime)';
}
