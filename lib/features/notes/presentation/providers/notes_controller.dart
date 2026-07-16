import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/di/usecase_providers.dart';
import '../../domain/entities/note.dart';

enum NotesSort { newest, favorites }

class NotesState {
  final List<Note> notes;
  final String searchQuery;
  final NotesSort sortBy;

  const NotesState({
    required this.notes,
    this.searchQuery = '',
    this.sortBy = NotesSort.newest,
  });

  NotesState copyWith({
    List<Note>? notes,
    String? searchQuery,
    NotesSort? sortBy,
  }) {
    return NotesState(
      notes: notes ?? this.notes,
      searchQuery: searchQuery ?? this.searchQuery,
      sortBy: sortBy ?? this.sortBy,
    );
  }

  List<Note> get filteredNotes {
    final normalizedQuery = searchQuery.trim().toLowerCase();
    final filtered = notes.where((note) {
      if (normalizedQuery.isEmpty) {
        return true;
      }
      final title = (note.title ?? '').toLowerCase();
      final content = note.content.toLowerCase();
      return title.contains(normalizedQuery) || content.contains(normalizedQuery);
    }).toList();

    filtered.sort((a, b) {
      if (sortBy == NotesSort.favorites) {
        final favoriteCompare = (b.isFavorite ? 1 : 0).compareTo(a.isFavorite ? 1 : 0);
        if (favoriteCompare != 0) {
          return favoriteCompare;
        }
      }
      return b.updatedAt.compareTo(a.updatedAt);
    });

    return filtered;
  }
}

/// Controls the state and operations of the Notes feature.
class NotesController extends AsyncNotifier<NotesState> {
  @override
  Future<NotesState> build() async {
    return _fetchState();
  }

  Future<NotesState> _fetchState() async {
    final getAllNotes = ref.read(getAllNotesProvider);
    final existing = state.valueOrNull;
    return NotesState(
      notes: await getAllNotes(),
      searchQuery: existing?.searchQuery ?? '',
      sortBy: existing?.sortBy ?? NotesSort.newest,
    );
  }

  Future<Note> saveNote(Note note) async {
    state = const AsyncLoading();

    final saved = note.id.isEmpty
        ? await ref.read(createNoteProvider)(
            title: note.title,
            content: note.content,
            tags: note.tags,
          )
        : await ref.read(updateNoteProvider)(note);

    state = await AsyncValue.guard(_fetchState);
    return saved;
  }

  Future<void> toggleFavorite(String id) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref.read(toggleFavoriteProvider)(id);
      return _fetchState();
    });
  }

  Future<void> deleteNote(String id) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref.read(deleteNoteProvider)(id);
      return _fetchState();
    });
  }

  void updateSearchQuery(String query) {
    final current = state.valueOrNull;
    if (current == null) {
      return;
    }
    state = AsyncData(current.copyWith(searchQuery: query));
  }

  void updateSort(NotesSort sortBy) {
    final current = state.valueOrNull;
    if (current == null) {
      return;
    }
    state = AsyncData(current.copyWith(sortBy: sortBy));
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(_fetchState);
  }
}

final notesControllerProvider = AsyncNotifierProvider<NotesController, NotesState>(() {
  return NotesController();
});
