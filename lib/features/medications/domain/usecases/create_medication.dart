import '../entities/medication.dart';
import '../repositories/medication_repository.dart';
import '../value_objects/dosage.dart';

/// Creates a new medication with dosage and schedule.
class CreateMedication {
  final MedicationRepository _repository;

  const CreateMedication(this._repository);

  Future<Medication> call({
    required String name,
    required Dosage dosage,
    required List<String> schedule,
    String? instructions,
    bool isActive = true,
  }) async {
    final medication = Medication(
      id: '',
      name: name,
      dosage: dosage,
      schedule: schedule,
      instructions: instructions,
      isActive: isActive,
    );
    return _repository.createMedication(medication);
  }
}
