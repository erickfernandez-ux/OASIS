import '../entities/mood_entry.dart';

/// Contract for MoodEntry data operations.
abstract class MoodRepository {
  /// Returns all mood entries ordered by date.
  Future<List<MoodEntry>> getAllEntries();

  /// Returns a single entry by id, or null if not found.
  Future<MoodEntry?> getEntryById(String id);

  /// Returns entries within the given date range.
  Future<List<MoodEntry>> getEntriesInRange(DateTime start, DateTime end);

  /// Persists a new mood entry.
  Future<MoodEntry> createEntry(MoodEntry entry);

  /// Updates an existing entry.
  Future<MoodEntry> updateEntry(MoodEntry entry);

  /// Deletes an entry by id.
  Future<bool> deleteEntry(String id);
}
