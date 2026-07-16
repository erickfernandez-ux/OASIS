import '../entities/water_entry.dart';

/// Registers a water intake entry.
/// This use case keeps the behavior isolated from persistence.
class RegisterWaterIntake {
  const RegisterWaterIntake();

  /// Creates a water entry. The persistence layer handles the save.
  WaterEntry call({required int amountMl, DateTime? date}) {
    return WaterEntry(
      id: '',
      amountMl: amountMl,
      dateTime: date ?? DateTime.now(),
    );
  }
}
