import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/di/usecase_providers.dart';
import '../../domain/entities/journal_entry.dart';

class JournalController extends AsyncNotifier<List<JournalEntry>> {
  @override
  Future<List<JournalEntry>> build() async {
    return _loadEntries();
  }

  Future<List<JournalEntry>> _loadEntries() async {
    final getAllJournalEntries = ref.read(getAllJournalEntriesProvider);
    return getAllJournalEntries();
  }

  Future<JournalEntry> saveEntry(JournalEntry entry) async {
    final saved = entry.id.isEmpty
        ? await ref.read(createJournalEntryProvider)(entry)
        : await ref.read(updateJournalEntryProvider)(entry);
    state = await AsyncValue.guard(_loadEntries);
    return saved;
  }

  Future<void> deleteEntry(String id) async {
    state = await AsyncValue.guard(() async {
      await ref.read(deleteJournalEntryProvider)(id);
      return _loadEntries();
    });
  }

  Future<void> refresh() async {
    state = await AsyncValue.guard(_loadEntries);
  }
}

final journalControllerProvider = AsyncNotifierProvider<JournalController, List<JournalEntry>>(() {
  return JournalController();
});
