import 'package:equatable/equatable.dart';

class SafetyProfessional extends Equatable {
  const SafetyProfessional({
    required this.id,
    required this.name,
    required this.role,
    required this.phone,
  });

  final String id;
  final String name;
  final String role;
  final String phone;

  SafetyProfessional copyWith({
    String? id,
    String? name,
    String? role,
    String? phone,
  }) {
    return SafetyProfessional(
      id: id ?? this.id,
      name: name ?? this.name,
      role: role ?? this.role,
      phone: phone ?? this.phone,
    );
  }

  @override
  List<Object?> get props => [id, name, role, phone];
}
