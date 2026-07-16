import '../entities/medication.dart';
import '../repositories/medication_repository.dart';

/// Marks a medication dose as taken.
/// This use case only coordinates the domain state change.
class MarkMedicationTaken {
  final MedicationRepository _repository;

  const MarkMedicationTaken(this._repository);

  Future<Medication> call(String id) async {
    final medication = await _repository.getMedicationById(id);
    if (medication == null) throw Exception('Medication not found');

    final updated = medication.copyWith(isActive: medication.isActive);
    return _repository.updateMedication(updated);
  }
}
