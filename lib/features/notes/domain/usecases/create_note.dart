import '../entities/note.dart';
import '../repositories/note_repository.dart';

/// Creates a new note with the given content.
/// Title is optional for quick captures.
class CreateNote {
  final NoteRepository _repository;

  const CreateNote(this._repository);

  Future<Note> call({
    String? title,
    required String content,
    List<String>? attachments,
    List<String>? tags,
  }) async {
    final now = DateTime.now();
    final note = Note(
      id: '',
      title: title,
      content: content,
      attachments: attachments ?? const [],
      createdAt: now,
      updatedAt: now,
      tags: tags ?? const [],
    );
    return _repository.createNote(note);
  }
}
