import '../entities/journal_entry.dart';

/// Contract for emotional journal persistence.
abstract class JournalRepository {
  Future<List<JournalEntry>> getAllJournalEntries();

  Future<JournalEntry?> getJournalEntryById(String id);

  Future<JournalEntry> createJournalEntry(JournalEntry entry);

  Future<JournalEntry> updateJournalEntry(JournalEntry entry);

  Future<bool> deleteJournalEntry(String id);
}
