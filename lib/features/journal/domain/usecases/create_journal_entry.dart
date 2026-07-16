import '../entities/journal_entry.dart';
import '../repositories/journal_repository.dart';

class CreateJournalEntry {
  const CreateJournalEntry(this._repository);

  final JournalRepository _repository;

  Future<JournalEntry> call(JournalEntry entry) {
    return _repository.createJournalEntry(entry);
  }
}
