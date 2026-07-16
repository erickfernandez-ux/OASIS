import 'package:uuid/uuid.dart';

import '../../../../core/utils/local_json_store.dart';
import '../../domain/entities/medication.dart';
import '../../domain/repositories/medication_repository.dart';
import '../../domain/value_objects/dosage.dart';

/// In-memory implementation of [MedicationRepository].
class MockMedicationRepository implements MedicationRepository {
  static const _storageKey = 'medications';
  final List<Medication> _medications = [];
  final _uuid = const Uuid();
  Future<void>? _initFuture;

  MockMedicationRepository() {
    _seedData();
  }

  void _seedData() {
    _medications.addAll([
      const Medication(
        id: 'med-001',
        name: 'Sertralina',
        dosage: Dosage(amount: 50, unit: DosageUnit.milligram),
        schedule: ['08:00'],
        instructions: 'Tomar con el desayuno',
        isActive: true,
      ),
      Medication(
        id: _uuid.v4(),
        name: 'Metformina',
        dosage: const Dosage(amount: 850, unit: DosageUnit.milligram),
        schedule: const ['08:00', '20:00'],
        instructions: 'Tomar con las comidas',
        isActive: true,
      ),
      Medication(
        id: _uuid.v4(),
        name: 'Melatonina',
        dosage: const Dosage(amount: 3, unit: DosageUnit.milligram),
        schedule: const ['22:00'],
        instructions: '30 minutos antes de dormir',
        isActive: true,
      ),
    ]);
  }

  @override
  Future<List<Medication>> getAllMedications() async {
    await _ensureInitialized();
    await _simulateNetworkDelay();
    return List.unmodifiable(_medications);
  }

  @override
  Future<Medication?> getMedicationById(String id) async {
    await _ensureInitialized();
    await _simulateNetworkDelay();
    try {
      return _medications.firstWhere((m) => m.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<List<Medication>> getActiveMedications() async {
    await _ensureInitialized();
    await _simulateNetworkDelay();
    return _medications.where((m) => m.isActive).toList();
  }

  @override
  Future<Medication> createMedication(Medication medication) async {
    await _ensureInitialized();
    await _simulateNetworkDelay();
    final created = medication.copyWith(id: medication.id.isEmpty ? _uuid.v4() : medication.id);
    _medications.add(created);
    await _persist();
    return created;
  }

  @override
  Future<Medication> updateMedication(Medication medication) async {
    await _ensureInitialized();
    await _simulateNetworkDelay();
    final index = _medications.indexWhere((m) => m.id == medication.id);
    if (index == -1) throw Exception('Medication not found: ${medication.id}');
    _medications[index] = medication;
    await _persist();
    return medication;
  }

  @override
  Future<bool> deleteMedication(String id) async {
    await _ensureInitialized();
    await _simulateNetworkDelay();
    final index = _medications.indexWhere((m) => m.id == id);
    if (index == -1) return false;
    _medications.removeAt(index);
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
      _medications.clear();
      return;
    }

    _medications
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
      _medications.map(_toJson).toList(growable: false),
    );
  }

  Map<String, dynamic> _toJson(Medication medication) {
    return {
      'id': medication.id,
      'name': medication.name,
      'dosageAmount': medication.dosage.amount,
      'dosageUnit': medication.dosage.unit.name,
      'schedule': medication.schedule,
      'instructions': medication.instructions,
      'isActive': medication.isActive,
    };
  }

  Medication _fromJson(Map<String, dynamic> json) {
    return Medication(
      id: (json['id'] as String?) ?? _uuid.v4(),
      name: (json['name'] as String?) ?? 'Medicamento',
      dosage: Dosage(
        amount: (json['dosageAmount'] as num?)?.toDouble() ?? 1,
        unit: DosageUnit.values.firstWhere(
          (item) => item.name == json['dosageUnit'],
          orElse: () => DosageUnit.tablet,
        ),
      ),
      schedule: (json['schedule'] as List?)
              ?.whereType<String>()
              .toList(growable: false) ??
          const <String>['08:00'],
      instructions: json['instructions'] as String?,
      isActive: (json['isActive'] as bool?) ?? true,
    );
  }

  Future<void> _simulateNetworkDelay() async {
    await Future.delayed(const Duration(milliseconds: 150));
  }
}
