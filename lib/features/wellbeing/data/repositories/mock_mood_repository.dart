import 'package:uuid/uuid.dart';

import '../../../../core/utils/local_json_store.dart';
import '../../domain/entities/mood_entry.dart';
import '../../domain/enums/mood_type.dart';
import '../../domain/repositories/mood_repository.dart';

/// In-memory implementation of [MoodRepository].
class MockMoodRepository implements MoodRepository {
  static const _storageKey = 'mood_entries';
  final List<MoodEntry> _entries = [];
  final _uuid = const Uuid();
  Future<void>? _initFuture;

  MockMoodRepository() {
    _seedData();
  }

  void _seedData() {
    final now = DateTime.now();
    _entries.addAll([
      MoodEntry(
        id: _uuid.v4(),
        mood: MoodType.happy,
        note: 'Día productivo, terminé el sprint a tiempo',
        date: now.subtract(const Duration(days: 1)),
      ),
      MoodEntry(
        id: _uuid.v4(),
        mood: MoodType.anxious,
        note: 'Reunión difícil con el cliente',
        date: now.subtract(const Duration(days: 3)),
      ),
      MoodEntry(
        id: _uuid.v4(),
        mood: MoodType.neutral,
        date: now.subtract(const Duration(days: 5)),
      ),
    ]);
  }

  @override
  Future<List<MoodEntry>> getAllEntries() async {
    await _ensureInitialized();
    await _simulateNetworkDelay();
    return List.unmodifiable(_entries..sort((a, b) => b.date.compareTo(a.date)));
  }

  @override
  Future<MoodEntry?> getEntryById(String id) async {
    await _ensureInitialized();
    await _simulateNetworkDelay();
    try {
      return _entries.firstWhere((e) => e.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<List<MoodEntry>> getEntriesInRange(DateTime start, DateTime end) async {
    await _ensureInitialized();
    await _simulateNetworkDelay();
    return _entries.where((e) => !e.date.isBefore(start) && !e.date.isAfter(end)).toList();
  }

  @override
  Future<MoodEntry> createEntry(MoodEntry entry) async {
    await _ensureInitialized();
    await _simulateNetworkDelay();
    final created = entry.copyWith(id: entry.id.isEmpty ? _uuid.v4() : entry.id);
    _entries.add(created);
    await _persist();
    return created;
  }

  @override
  Future<MoodEntry> updateEntry(MoodEntry entry) async {
    await _ensureInitialized();
    await _simulateNetworkDelay();
    final index = _entries.indexWhere((e) => e.id == entry.id);
    if (index == -1) throw Exception('MoodEntry not found: ${entry.id}');
    _entries[index] = entry;
    await _persist();
    return entry;
  }

  @override
  Future<bool> deleteEntry(String id) async {
    await _ensureInitialized();
    await _simulateNetworkDelay();
    final index = _entries.indexWhere((e) => e.id == id);
    if (index == -1) return false;
    _entries.removeAt(index);
    await _persist();
    return true;
  }

  Future<void> _ensureInitialized() {
    _initFuture ??= _loadFromStorage();
    return _initFuture!;
  }

  Future<void> _loadFromStorage() async {
    final raw = await LocalJsonStore.readList(_storageKey);
    if (raw == null || raw.isEmpty) {
      return;
    }

    _entries
      ..clear()
      ..addAll(
        raw
            .whereType<Map>()
            .map((item) => _fromJson(item.cast<String, dynamic>())),
      );
  }

  Future<void> _persist() async {
    await LocalJsonStore.writeList(
      _storageKey,
      _entries.map(_toJson).toList(growable: false),
    );
  }

  Map<String, dynamic> _toJson(MoodEntry entry) {
    return {
      'id': entry.id,
      'mood': entry.mood.name,
      'note': entry.note,
      'date': entry.date.toIso8601String(),
    };
  }

  MoodEntry _fromJson(Map<String, dynamic> json) {
    return MoodEntry(
      id: (json['id'] as String?) ?? _uuid.v4(),
      mood: MoodType.values.firstWhere(
        (item) => item.name == json['mood'],
        orElse: () => MoodType.neutral,
      ),
      note: json['note'] as String?,
      date: DateTime.tryParse((json['date'] as String?) ?? '') ?? DateTime.now(),
    );
  }

  Future<void> _simulateNetworkDelay() async {
    await Future.delayed(const Duration(milliseconds: 150));
  }
}
