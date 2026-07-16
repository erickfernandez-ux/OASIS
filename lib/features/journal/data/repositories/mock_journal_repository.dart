import 'package:uuid/uuid.dart';

import '../../../../core/utils/local_json_store.dart';
import '../../domain/entities/journal_entry.dart';
import '../../domain/enums/journal_emotion.dart';
import '../../domain/repositories/journal_repository.dart';

class MockJournalRepository implements JournalRepository {
  static const _storageKey = 'journal_entries';
  final List<JournalEntry> _entries = [];
  final _uuid = const Uuid();
  Future<void>? _initFuture;

  MockJournalRepository() {
    _seedData();
  }

  void _seedData() {
    final now = DateTime.now();
    _entries.addAll([
      JournalEntry(
        id: _uuid.v4(),
        emotion: JournalEmotion.serene,
        secondaryEmotions: const ['En calma', 'Agradecido'],
        intensity: 7,
        energy: 6,
        sleepHours: 7.5,
        anxiety: 3,
        irritability: 2,
        medicationTaken: true,
        pain: 2,
        stress: 4,
        happenedToday:
            'Hoy todo se sintió más lento y eso me ayudó a respirar mejor.',
        bestPart: 'Tomé un té en silencio antes de empezar.',
        hardestPart: 'Me costó mucho arrancar por la mañana.',
        gratitude: 'Agradezco haber podido pausar.',
        learnedToday:
            'Pausar cinco minutos al despertar cambia el resto del día.',
        selfCareWater: true,
        selfCareFood: true,
        selfCareMedication: true,
        selfCareMovement: false,
        selfCareRest: true,
        bodyCheckIns: const ['Dormí bien', 'Tomé agua', 'Respiré'],
        createdAt: now.subtract(const Duration(days: 1)),
        updatedAt: now.subtract(const Duration(days: 1)),
      ),
      JournalEntry(
        id: _uuid.v4(),
        emotion: JournalEmotion.grateful,
        secondaryEmotions: const ['Conectado', 'Con esperanza'],
        intensity: 8,
        energy: 7,
        sleepHours: 8,
        anxiety: 2,
        irritability: 1,
        medicationTaken: true,
        pain: 1,
        stress: 3,
        happenedToday: 'Tuve una conversación amable que me dejó más liviano.',
        bestPart: 'Sentí apoyo sin tener que explicarme demasiado.',
        hardestPart: 'Hubo un momento de cansancio al final del día.',
        gratitude: 'Agradezco a quien me escuchó con paciencia.',
        learnedToday: 'Pedir ayuda breve y concreta funciona mejor para mí.',
        selfCareWater: true,
        selfCareFood: true,
        selfCareMedication: true,
        selfCareMovement: true,
        selfCareRest: true,
        bodyCheckIns: const [
          'Comí suficiente',
          'Hablé con alguien',
          'Descansé'
        ],
        createdAt: now.subtract(const Duration(days: 2)),
        updatedAt: now.subtract(const Duration(days: 2)),
      ),
      JournalEntry(
        id: _uuid.v4(),
        emotion: JournalEmotion.anxious,
        secondaryEmotions: const ['Tenso', 'Cansado'],
        intensity: 4,
        energy: 3,
        sleepHours: 5.5,
        anxiety: 8,
        irritability: 7,
        medicationTaken: false,
        pain: 4,
        stress: 8,
        happenedToday:
            'Hoy hubo demasiadas cosas a la vez y me sentí disperso.',
        bestPart: 'Pude ordenar una sola prioridad.',
        hardestPart: 'La tarde se sintió pesada y ruidosa.',
        gratitude: 'Agradezco haberme detenido antes de seguir forzando.',
        learnedToday:
            'Cuando todo sube, volver al cuerpo me ayuda a no colapsar.',
        selfCareWater: false,
        selfCareFood: true,
        selfCareMedication: false,
        selfCareMovement: false,
        selfCareRest: false,
        bodyCheckIns: const ['Tomé mis medicamentos', 'Me moví'],
        createdAt: now.subtract(const Duration(days: 3)),
        updatedAt: now.subtract(const Duration(days: 3)),
      ),
    ]);
  }

  @override
  Future<List<JournalEntry>> getAllJournalEntries() async {
    await _ensureInitialized();
    await Future.delayed(const Duration(milliseconds: 120));
    return List.unmodifiable(
        _entries..sort((a, b) => b.updatedAt.compareTo(a.updatedAt)));
  }

  @override
  Future<JournalEntry?> getJournalEntryById(String id) async {
    await _ensureInitialized();
    await Future.delayed(const Duration(milliseconds: 120));
    try {
      return _entries.firstWhere((entry) => entry.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<JournalEntry> createJournalEntry(JournalEntry entry) async {
    await _ensureInitialized();
    await Future.delayed(const Duration(milliseconds: 120));
    final created =
        entry.copyWith(id: entry.id.isEmpty ? _uuid.v4() : entry.id);
    _entries.add(created);
    await _persist();
    return created;
  }

  @override
  Future<JournalEntry> updateJournalEntry(JournalEntry entry) async {
    await _ensureInitialized();
    await Future.delayed(const Duration(milliseconds: 120));
    final index = _entries.indexWhere((item) => item.id == entry.id);
    if (index == -1) {
      throw Exception('Journal entry not found: ${entry.id}');
    }
    _entries[index] = entry.copyWith(updatedAt: DateTime.now());
    await _persist();
    return _entries[index];
  }

  @override
  Future<bool> deleteJournalEntry(String id) async {
    await _ensureInitialized();
    await Future.delayed(const Duration(milliseconds: 120));
    final index = _entries.indexWhere((item) => item.id == id);
    if (index == -1) {
      return false;
    }
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
    if (raw == null) {
      return;
    }
    if (raw.isEmpty) {
      _entries.clear();
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

  Map<String, dynamic> _toJson(JournalEntry entry) {
    return {
      'id': entry.id,
      'emotion': entry.emotion.name,
      'secondaryEmotions': entry.secondaryEmotions,
      'intensity': entry.intensity,
      'energy': entry.energy,
      'sleepHours': entry.sleepHours,
      'anxiety': entry.anxiety,
      'irritability': entry.irritability,
      'medicationTaken': entry.medicationTaken,
      'pain': entry.pain,
      'stress': entry.stress,
      'happenedToday': entry.happenedToday,
      'bestPart': entry.bestPart,
      'hardestPart': entry.hardestPart,
      'gratitude': entry.gratitude,
      'learnedToday': entry.learnedToday,
      'selfCareWater': entry.selfCareWater,
      'selfCareFood': entry.selfCareFood,
      'selfCareMedication': entry.selfCareMedication,
      'selfCareMovement': entry.selfCareMovement,
      'selfCareRest': entry.selfCareRest,
      'bodyCheckIns': entry.bodyCheckIns,
      'createdAt': entry.createdAt.toIso8601String(),
      'updatedAt': entry.updatedAt.toIso8601String(),
    };
  }

  JournalEntry _fromJson(Map<String, dynamic> json) {
    return JournalEntry(
      id: (json['id'] as String?) ?? _uuid.v4(),
      emotion: JournalEmotion.values.firstWhere(
        (item) => item.name == json['emotion'],
        orElse: () => JournalEmotion.neutral,
      ),
      secondaryEmotions:
          (json['secondaryEmotions'] as List?)?.whereType<String>().toList() ??
              const <String>[],
      intensity: (json['intensity'] as num?)?.toDouble() ?? 5,
      energy: (json['energy'] as num?)?.toDouble() ?? 5,
      sleepHours: (json['sleepHours'] as num?)?.toDouble() ?? 7,
      anxiety: (json['anxiety'] as num?)?.toDouble() ?? 5,
      irritability: (json['irritability'] as num?)?.toDouble() ?? 4,
      medicationTaken: (json['medicationTaken'] as bool?) ?? false,
      pain: (json['pain'] as num?)?.toDouble() ?? 3,
      stress: (json['stress'] as num?)?.toDouble() ?? 5,
      happenedToday: (json['happenedToday'] as String?) ?? '',
      bestPart: (json['bestPart'] as String?) ?? '',
      hardestPart: (json['hardestPart'] as String?) ?? '',
      gratitude: (json['gratitude'] as String?) ?? '',
      learnedToday: (json['learnedToday'] as String?) ?? '',
      selfCareWater: (json['selfCareWater'] as bool?) ?? false,
      selfCareFood: (json['selfCareFood'] as bool?) ?? false,
      selfCareMedication: (json['selfCareMedication'] as bool?) ?? false,
      selfCareMovement: (json['selfCareMovement'] as bool?) ?? false,
      selfCareRest: (json['selfCareRest'] as bool?) ?? false,
      bodyCheckIns:
          (json['bodyCheckIns'] as List?)?.whereType<String>().toList() ??
              const <String>[],
      createdAt: DateTime.tryParse((json['createdAt'] as String?) ?? '') ??
          DateTime.now(),
      updatedAt: DateTime.tryParse((json['updatedAt'] as String?) ?? '') ??
          DateTime.now(),
    );
  }
}
