import '../entities/mood_entry.dart';
import '../enums/mood_type.dart';
import '../repositories/mood_repository.dart';

/// Records a new mood entry at the current time.
class CreateMoodEntry {
  final MoodRepository _repository;

  const CreateMoodEntry(this._repository);

  Future<MoodEntry> call({
    required MoodType mood,
    String? note,
    DateTime? date,
  }) async {
    final entry = MoodEntry(
      id: '',
      mood: mood,
      note: note,
      date: date ?? DateTime.now(),
    );
    return _repository.createEntry(entry);
  }
}
