import '../entities/journal_entry.dart';
import '../repositories/journal_repository.dart';

class UpdateJournalEntry {
  const UpdateJournalEntry(this._repository);

  final JournalRepository _repository;

  Future<JournalEntry> call(JournalEntry entry) {
    return _repository.updateJournalEntry(entry);
  }
}
