import '../entities/medication.dart';
import '../repositories/medication_repository.dart';

/// Retrieves all medications.
class GetMedications {
  final MedicationRepository _repository;

  const GetMedications(this._repository);

  Future<List<Medication>> call() async {
    return _repository.getAllMedications();
  }
}
