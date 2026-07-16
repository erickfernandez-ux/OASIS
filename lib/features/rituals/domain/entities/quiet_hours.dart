import 'package:equatable/equatable.dart';

class QuietHours extends Equatable {
  const QuietHours({
    required this.enabled,
    required this.startHour,
    required this.startMinute,
    required this.endHour,
    required this.endMinute,
  });

  final bool enabled;
  final int startHour;
  final int startMinute;
  final int endHour;
  final int endMinute;

  QuietHours copyWith({
    bool? enabled,
    int? startHour,
    int? startMinute,
    int? endHour,
    int? endMinute,
  }) {
    return QuietHours(
      enabled: enabled ?? this.enabled,
      startHour: startHour ?? this.startHour,
      startMinute: startMinute ?? this.startMinute,
      endHour: endHour ?? this.endHour,
      endMinute: endMinute ?? this.endMinute,
    );
  }

  @override
  List<Object?> get props => [
        enabled,
        startHour,
        startMinute,
        endHour,
        endMinute,
      ];
}
