import 'package:equatable/equatable.dart';

/// Represents a medication dosage with amount and unit.
/// Encapsulates the concept to avoid unstructured strings like "10mg".
class Dosage extends Equatable {
  final double amount;
  final DosageUnit unit;

  const Dosage({
    required this.amount,
    required this.unit,
  });

  /// Validates that the dosage amount is positive.
  String? validate() {
    if (amount <= 0) return 'Dosage amount must be greater than zero';
    return null;
  }

  bool get isValid => validate() == null;

  @override
  List<Object?> get props => [amount, unit];

  @override
  String toString() => '$amount${unit.symbol}';
}

/// Units of measurement for medication dosage.
enum DosageUnit {
  milligram('mg'),
  milliliter('ml'),
  tablet('tablet'),
  drop('drop'),
  teaspoon('tsp'),
  tablespoon('tbsp');

  final String symbol;
  const DosageUnit(this.symbol);
}
