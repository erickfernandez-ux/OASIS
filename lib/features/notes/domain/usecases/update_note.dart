import '../entities/note.dart';
import '../repositories/note_repository.dart';

/// Updates an existing note and refreshes the updatedAt timestamp.
class UpdateNote {
  final NoteRepository _repository;

  const UpdateNote(this._repository);

  Future<Note> call(Note note) async {
    final updated = note.copyWith(updatedAt: DateTime.now());
    return _repository.updateNote(updated);
  }
}
