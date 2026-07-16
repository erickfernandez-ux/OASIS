import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/di/usecase_providers.dart';
import '../../domain/entities/medication.dart';
import '../../domain/value_objects/dosage.dart';

/// Controls the state and operations of the Medications feature.
class MedicationsController extends AsyncNotifier<List<Medication>> {
  @override
  Future<List<Medication>> build() async {
    return _fetchMedications();
  }

  Future<List<Medication>> _fetchMedications() async {
    final getMedications = ref.read(getMedicationsProvider);
    return getMedications();
  }

  /// Creates a new medication.
  Future<void> createMedication({
    required String name,
    required Dosage dosage,
    required List<String> schedule,
    String? instructions,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final createMedication = ref.read(createMedicationProvider);
      await createMedication(
        name: name,
        dosage: dosage,
        schedule: schedule,
        instructions: instructions,
      );
      return _fetchMedications();
    });
  }

  Future<void> updateMedication(Medication medication) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final updateMedication = ref.read(updateMedicationProvider);
      await updateMedication(medication);
      return _fetchMedications();
    });
  }

  /// Marks a medication as taken.
  Future<void> markTaken(String id) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final markTaken = ref.read(markMedicationTakenProvider);
      await markTaken(id);
      return _fetchMedications();
    });
  }

  /// Deletes a medication.
  Future<void> deleteMedication(String id) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final deleteMedication = ref.read(deleteMedicationProvider);
      await deleteMedication(id);
      return _fetchMedications();
    });
  }

  /// Refreshes the medications list.
  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(_fetchMedications);
  }
}

final medicationsControllerProvider =
    AsyncNotifierProvider<MedicationsController, List<Medication>>(() {
  return MedicationsController();
});
