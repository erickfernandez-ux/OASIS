import '../entities/mood_entry.dart';
import '../repositories/mood_repository.dart';

/// Retrieves mood entries within a date range.
/// If no range is provided, returns all entries.
class GetMoodHistory {
  final MoodRepository _repository;

  const GetMoodHistory(this._repository);

  Future<List<MoodEntry>> call({DateTime? start, DateTime? end}) async {
    if (start != null && end != null) {
      return _repository.getEntriesInRange(start, end);
    }
    return _repository.getAllEntries();
  }
}
