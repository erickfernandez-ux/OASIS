import '../entities/journal_entry.dart';
import '../repositories/journal_repository.dart';

class GetAllJournalEntries {
  const GetAllJournalEntries(this._repository);

  final JournalRepository _repository;

  Future<List<JournalEntry>> call() {
    return _repository.getAllJournalEntries();
  }
}
