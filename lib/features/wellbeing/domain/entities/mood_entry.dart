import 'package:equatable/equatable.dart';

import '../enums/mood_type.dart';

/// Represents a subjective emotional state capture at a specific moment.
/// The emotional biometrics of OASIS.
class MoodEntry extends Equatable {
  final String id;
  final MoodType mood;
  final String? note;
  final DateTime date;

  const MoodEntry({
    required this.id,
    required this.mood,
    this.note,
    required this.date,
  });

  MoodEntry copyWith({
    String? id,
    MoodType? mood,
    String? note,
    DateTime? date,
  }) {
    return MoodEntry(
      id: id ?? this.id,
      mood: mood ?? this.mood,
      note: note ?? this.note,
      date: date ?? this.date,
    );
  }

  @override
  List<Object?> get props => [id, mood, note, date];

  @override
  String toString() => 'MoodEntry(id: $id, mood: $mood, date: $date)';
}
