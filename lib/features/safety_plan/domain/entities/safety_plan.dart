import 'package:equatable/equatable.dart';

import 'safety_contact.dart';
import 'safety_professional.dart';

class SafetyPlan extends Equatable {
  const SafetyPlan({
    required this.warningSigns,
    required this.selfActions,
    required this.safePlaces,
    required this.contacts,
    required this.professionals,
    required this.reasonsToStay,
    required this.crisisMode,
    required this.updatedAt,
  });

  final List<String> warningSigns;
  final List<String> selfActions;
  final List<String> safePlaces;
  final List<SafetyContact> contacts;
  final List<SafetyProfessional> professionals;
  final List<String> reasonsToStay;
  final bool crisisMode;
  final DateTime updatedAt;

  SafetyPlan copyWith({
    List<String>? warningSigns,
    List<String>? selfActions,
    List<String>? safePlaces,
    List<SafetyContact>? contacts,
    List<SafetyProfessional>? professionals,
    List<String>? reasonsToStay,
    bool? crisisMode,
    DateTime? updatedAt,
  }) {
    return SafetyPlan(
      warningSigns: warningSigns ?? this.warningSigns,
      selfActions: selfActions ?? this.selfActions,
      safePlaces: safePlaces ?? this.safePlaces,
      contacts: contacts ?? this.contacts,
      professionals: professionals ?? this.professionals,
      reasonsToStay: reasonsToStay ?? this.reasonsToStay,
      crisisMode: crisisMode ?? this.crisisMode,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        warningSigns,
        selfActions,
        safePlaces,
        contacts,
        professionals,
        reasonsToStay,
        crisisMode,
        updatedAt,
      ];
}
