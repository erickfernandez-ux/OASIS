import '../repositories/journal_repository.dart';

class DeleteJournalEntry {
  const DeleteJournalEntry(this._repository);

  final JournalRepository _repository;

  Future<bool> call(String id) {
    return _repository.deleteJournalEntry(id);
  }
}
