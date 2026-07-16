import 'package:equatable/equatable.dart';

class SafetyContact extends Equatable {
  const SafetyContact({
    required this.id,
    required this.name,
    required this.relationship,
    required this.phone,
    required this.quickMessage,
  });

  final String id;
  final String name;
  final String relationship;
  final String phone;
  final String quickMessage;

  SafetyContact copyWith({
    String? id,
    String? name,
    String? relationship,
    String? phone,
    String? quickMessage,
  }) {
    return SafetyContact(
      id: id ?? this.id,
      name: name ?? this.name,
      relationship: relationship ?? this.relationship,
      phone: phone ?? this.phone,
      quickMessage: quickMessage ?? this.quickMessage,
    );
  }

  @override
  List<Object?> get props => [id, name, relationship, phone, quickMessage];
}
