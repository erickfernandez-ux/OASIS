import '../entities/note.dart';
import '../repositories/note_repository.dart';

/// Retrieves all notes ordered by updated date.
class GetAllNotes {
  final NoteRepository _repository;

  const GetAllNotes(this._repository);

  Future<List<Note>> call() async {
    return _repository.getAllNotes();
  }
}
