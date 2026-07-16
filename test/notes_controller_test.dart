import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:oasis/features/notes/domain/entities/note.dart';
import 'package:oasis/features/notes/presentation/providers/notes_controller.dart';

void main() {
  test('creates, favorites and deletes a note through the controller', () async {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final controller = container.read(notesControllerProvider.notifier);

    final created = await controller.saveNote(
      Note(
        id: '',
        title: 'Test note',
        content: 'Body',
        createdAt: DateTime(2026, 6, 30),
        updatedAt: DateTime(2026, 6, 30),
      ),
    );

    expect(created.id, isNotEmpty);

    await controller.toggleFavorite(created.id);
    final state = await controller.future;
    final favorite = state.notes.firstWhere((note) => note.id == created.id);
    expect(favorite.isFavorite, isTrue);

    await controller.deleteNote(created.id);
    final afterDelete = await controller.future;
    expect(afterDelete.notes.any((note) => note.id == created.id), isFalse);
  });
}
