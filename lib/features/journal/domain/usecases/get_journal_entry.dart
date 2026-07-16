import '../entities/journal_entry.dart';
import '../repositories/journal_repository.dart';

class GetJournalEntry {
  const GetJournalEntry(this._repository);

  final JournalRepository _repository;

  Future<JournalEntry?> call(String id) {
    return _repository.getJournalEntryById(id);
  }
}
