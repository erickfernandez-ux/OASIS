import '../entities/medication.dart';

/// Contract for Medication data operations.
abstract class MedicationRepository {
  /// Returns all medications.
  Future<List<Medication>> getAllMedications();

  /// Returns a single medication by id, or null if not found.
  Future<Medication?> getMedicationById(String id);

  /// Returns only active medications.
  Future<List<Medication>> getActiveMedications();

  /// Persists a new medication.
  Future<Medication> createMedication(Medication medication);

  /// Updates an existing medication.
  Future<Medication> updateMedication(Medication medication);

  /// Deletes a medication by id.
  Future<bool> deleteMedication(String id);
}
