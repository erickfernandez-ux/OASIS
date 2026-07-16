import 'package:uuid/uuid.dart';

import '../../../../core/privacy/privacy_store_manifest.dart';
import '../../../../core/utils/local_json_store.dart';
import '../../domain/entities/note.dart';
import '../../domain/repositories/note_repository.dart';

/// In-memory implementation of [NoteRepository].
class MockNoteRepository implements NoteRepository {
  static const _storageKey = PrivacyStoreManifest.notesKey;
  final List<Note> _notes = [];
  final _uuid = const Uuid();
  Future<void>? _initFuture;

  MockNoteRepository() {
    _seedData();
  }

  void _seedData() {
    final now = DateTime.now();
    _notes.addAll([
      Note(
        id: _uuid.v4(),
        title: 'Ideas para el proyecto OASIS',
        content: '1. Integrar calendario lunar para hábitos\n2. Modo zen sin notificaciones\n3. Colores pastel para TEA',
        isFavorite: true,
        createdAt: now.subtract(const Duration(days: 5)),
        updatedAt: now.subtract(const Duration(days: 2)),
        tags: const ['ideas', 'oasis'],
      ),
      Note(
        id: _uuid.v4(),
        title: 'Receta de granola casera',
        content: 'Avena, miel, nueces, coco. Horno 180°C por 20 minutos. Revolver cada 5 min.',
        createdAt: now.subtract(const Duration(days: 10)),
        updatedAt: now.subtract(const Duration(days: 10)),
        tags: const ['recetas', 'hogar'],
      ),
      Note(
        id: _uuid.v4(),
        content: 'Recordar: el cable HDMI está en el cajón del escritorio, junto a los post-its azules.',
        createdAt: now.subtract(const Duration(days: 1)),
        updatedAt: now.subtract(const Duration(days: 1)),
        tags: const ['recordatorio rápido'],
      ),
    ]);
  }

  @override
  Future<List<Note>> getAllNotes() async {
    await _ensureInitialized();
    await _simulateNetworkDelay();
    return List.unmodifiable(_notes..sort((a, b) => b.updatedAt.compareTo(a.updatedAt)));
  }

  @override
  Future<Note?> getNoteById(String id) async {
    await _ensureInitialized();
    await _simulateNetworkDelay();
    try {
      return _notes.firstWhere((n) => n.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<List<Note>> getFavoriteNotes() async {
    await _ensureInitialized();
    await _simulateNetworkDelay();
    return _notes.where((n) => n.isFavorite).toList();
  }

  @override
  Future<List<Note>> getNotesByTag(String tag) async {
    await _ensureInitialized();
    await _simulateNetworkDelay();
    return _notes.where((n) => n.tags.contains(tag)).toList();
  }

  @override
  Future<Note> createNote(Note note) async {
    await _ensureInitialized();
    await _simulateNetworkDelay();
    final created = note.copyWith(id: note.id.isEmpty ? _uuid.v4() : note.id);
    _notes.add(created);
    await _persist();
    return created;
  }

  @override
  Future<Note> updateNote(Note note) async {
    await _ensureInitialized();
    await _simulateNetworkDelay();
    final index = _notes.indexWhere((n) => n.id == note.id);
    if (index == -1) throw Exception('Note not found: ${note.id}');
    _notes[index] = note.copyWith(updatedAt: DateTime.now());
    await _persist();
    return _notes[index];
  }

  @override
  Future<bool> deleteNote(String id) async {
    await _ensureInitialized();
    await _simulateNetworkDelay();
    final index = _notes.indexWhere((n) => n.id == id);
    if (index == -1) return false;
    _notes.removeAt(index);
    await _persist();
    return true;
  }

  Future<void> _ensureInitialized() {
    _initFuture ??= _loadFromStorage();
    return _initFuture!;
  }

  Future<void> _loadFromStorage() async {
    final raw = await LocalJsonStore.readList(_storageKey);
    if (raw == null) {
      return;
    }
    if (raw.isEmpty) {
      _notes.clear();
      return;
    }

    _notes
      ..clear()
      ..addAll(raw.whereType<Map>().map((item) => _fromJson(item.cast<String, dynamic>())));
  }

  Future<void> _persist() async {
    await LocalJsonStore.writeList(
      _storageKey,
      _notes.map(_toJson).toList(growable: false),
    );
  }

  Map<String, dynamic> _toJson(Note note) {
    return {
      'id': note.id,
      'title': note.title,
      'content': note.content,
      'isFavorite': note.isFavorite,
      'createdAt': note.createdAt.toIso8601String(),
      'updatedAt': note.updatedAt.toIso8601String(),
      'tags': note.tags,
      'attachments': note.attachments,
    };
  }

  Note _fromJson(Map<String, dynamic> json) {
    return Note(
      id: (json['id'] as String?) ?? _uuid.v4(),
      title: json['title'] as String?,
      content: (json['content'] as String?) ?? '',
      isFavorite: (json['isFavorite'] as bool?) ?? false,
      createdAt: DateTime.tryParse((json['createdAt'] as String?) ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse((json['updatedAt'] as String?) ?? '') ?? DateTime.now(),
      tags: (json['tags'] as List?)?.whereType<String>().toList(growable: false) ?? const <String>[],
      attachments: (json['attachments'] as List?)?.whereType<String>().toList(growable: false) ?? const <String>[],
    );
  }

  Future<void> _simulateNetworkDelay() async {
    await Future.delayed(const Duration(milliseconds: 150));
  }
}
