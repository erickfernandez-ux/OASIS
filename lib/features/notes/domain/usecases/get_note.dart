import '../entities/note.dart';
import '../repositories/note_repository.dart';

/// Retrieves a single note by its unique identifier.
class GetNote {
  final NoteRepository _repository;

  const GetNote(this._repository);

  Future<Note?> call(String id) async {
    return _repository.getNoteById(id);
  }
}
