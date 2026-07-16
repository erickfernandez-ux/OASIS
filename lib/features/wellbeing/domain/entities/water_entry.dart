import 'package:equatable/equatable.dart';

/// Represents a hydration intake record.
/// The simplest physical habit tracker in OASIS.
class WaterEntry extends Equatable {
  final String id;
  final int amountMl;
  final DateTime dateTime;

  const WaterEntry({
    required this.id,
    required this.amountMl,
    required this.dateTime,
  });

  WaterEntry copyWith({
    String? id,
    int? amountMl,
    DateTime? dateTime,
  }) {
    return WaterEntry(
      id: id ?? this.id,
      amountMl: amountMl ?? this.amountMl,
      dateTime: dateTime ?? this.dateTime,
    );
  }

  @override
  List<Object?> get props => [id, amountMl, dateTime];

  @override
  String toString() => 'WaterEntry(id: $id, amount: ${amountMl}ml)';
}
