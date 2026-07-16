import '../repositories/note_repository.dart';

/// Permanently removes a note from the system.
class DeleteNote {
  final NoteRepository _repository;

  const DeleteNote(this._repository);

  Future<bool> call(String id) async {
    return _repository.deleteNote(id);
  }
}
