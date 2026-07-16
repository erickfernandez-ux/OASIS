import 'package:equatable/equatable.dart';

import '../enums/ritual_type.dart';

class Ritual extends Equatable {
  const Ritual({
    required this.id,
    required this.type,
    required this.enabled,
    required this.hour,
    required this.minute,
    required this.title,
    required this.description,
  });

  final String id;
  final RitualType type;
  final bool enabled;
  final int hour;
  final int minute;
  final String title;
  final String description;

  Ritual copyWith({
    String? id,
    RitualType? type,
    bool? enabled,
    int? hour,
    int? minute,
    String? title,
    String? description,
  }) {
    return Ritual(
      id: id ?? this.id,
      type: type ?? this.type,
      enabled: enabled ?? this.enabled,
      hour: hour ?? this.hour,
      minute: minute ?? this.minute,
      title: title ?? this.title,
      description: description ?? this.description,
    );
  }

  @override
  List<Object?> get props => [
        id,
        type,
        enabled,
        hour,
        minute,
        title,
        description,
      ];
}
