import 'package:equatable/equatable.dart';

import '../value_objects/dosage.dart';

/// Represents a pharmaceutical treatment with temporal adherence tracking.
class Medication extends Equatable {
  final String id;
  final String name;
  final Dosage dosage;
  final List<String> schedule;
  final String? instructions;
  final bool isActive;

  const Medication({
    required this.id,
    required this.name,
    required this.dosage,
    required this.schedule,
    this.instructions,
    this.isActive = true,
  });

  Medication copyWith({
    String? id,
    String? name,
    Dosage? dosage,
    List<String>? schedule,
    String? instructions,
    bool? isActive,
  }) {
    return Medication(
      id: id ?? this.id,
      name: name ?? this.name,
      dosage: dosage ?? this.dosage,
      schedule: schedule ?? this.schedule,
      instructions: instructions ?? this.instructions,
      isActive: isActive ?? this.isActive,
    );
  }

  @override
  List<Object?> get props => [id, name, dosage, schedule, instructions, isActive];

  @override
  String toString() => 'Medication(id: $id, name: $name, dosage: $dosage)';
}
