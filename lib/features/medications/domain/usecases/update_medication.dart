import '../entities/medication.dart';
import '../repositories/medication_repository.dart';

/// Updates an existing medication's information.
class UpdateMedication {
  final MedicationRepository _repository;

  const UpdateMedication(this._repository);

  Future<Medication> call(Medication medication) async {
    return _repository.updateMedication(medication);
  }
}
