import '../entities/note.dart';

/// Contract for Note data operations.
abstract class NoteRepository {
  /// Returns all notes ordered by updated date.
  Future<List<Note>> getAllNotes();

  /// Returns a single note by id, or null if not found.
  Future<Note?> getNoteById(String id);

  /// Returns favorite notes.
  Future<List<Note>> getFavoriteNotes();

  /// Returns notes matching the given tag.
  Future<List<Note>> getNotesByTag(String tag);

  /// Persists a new note.
  Future<Note> createNote(Note note);

  /// Updates an existing note.
  Future<Note> updateNote(Note note);

  /// Deletes a note by id.
  Future<bool> deleteNote(String id);
}
