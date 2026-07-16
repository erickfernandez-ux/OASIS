import '../entities/note.dart';
import '../repositories/note_repository.dart';

/// Toggles the favorite status of a note.
class ToggleFavorite {
  final NoteRepository _repository;

  const ToggleFavorite(this._repository);

  Future<Note> call(String id) async {
    final note = await _repository.getNoteById(id);
    if (note == null) throw Exception('Note not found');

    final toggled = note.copyWith(isFavorite: !note.isFavorite);
    return _repository.updateNote(toggled);
  }
}
