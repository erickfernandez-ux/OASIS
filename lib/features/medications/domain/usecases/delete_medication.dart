import '../repositories/medication_repository.dart';

/// Permanently removes a medication from the system.
class DeleteMedication {
  final MedicationRepository _repository;

  const DeleteMedication(this._repository);

  Future<bool> call(String id) async {
    return _repository.deleteMedication(id);
  }
}
