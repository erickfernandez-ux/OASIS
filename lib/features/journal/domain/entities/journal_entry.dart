import 'package:equatable/equatable.dart';

import '../enums/journal_emotion.dart';

/// A quiet, reflective emotional journal entry.
class JournalEntry extends Equatable {
  const JournalEntry({
    required this.id,
    required this.emotion,
    required this.secondaryEmotions,
    required this.intensity,
    required this.energy,
    required this.sleepHours,
    required this.anxiety,
    required this.irritability,
    required this.medicationTaken,
    required this.pain,
    required this.stress,
    required this.happenedToday,
    required this.bestPart,
    required this.hardestPart,
    required this.gratitude,
    required this.learnedToday,
    required this.selfCareWater,
    required this.selfCareFood,
    required this.selfCareMedication,
    required this.selfCareMovement,
    required this.selfCareRest,
    required this.bodyCheckIns,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final JournalEmotion emotion;
  final List<String> secondaryEmotions;
  final double intensity;
  final double energy;
  final double sleepHours;
  final double anxiety;
  final double irritability;
  final bool medicationTaken;
  final double pain;
  final double stress;
  final String happenedToday;
  final String bestPart;
  final String hardestPart;
  final String gratitude;
  final String learnedToday;
  final bool selfCareWater;
  final bool selfCareFood;
  final bool selfCareMedication;
  final bool selfCareMovement;
  final bool selfCareRest;
  final List<String> bodyCheckIns;
  final DateTime createdAt;
  final DateTime updatedAt;

  JournalEntry copyWith({
    String? id,
    JournalEmotion? emotion,
    List<String>? secondaryEmotions,
    double? intensity,
    double? energy,
    double? sleepHours,
    double? anxiety,
    double? irritability,
    bool? medicationTaken,
    double? pain,
    double? stress,
    String? happenedToday,
    String? bestPart,
    String? hardestPart,
    String? gratitude,
    String? learnedToday,
    bool? selfCareWater,
    bool? selfCareFood,
    bool? selfCareMedication,
    bool? selfCareMovement,
    bool? selfCareRest,
    List<String>? bodyCheckIns,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return JournalEntry(
      id: id ?? this.id,
      emotion: emotion ?? this.emotion,
      secondaryEmotions: secondaryEmotions ?? this.secondaryEmotions,
      intensity: intensity ?? this.intensity,
      energy: energy ?? this.energy,
      sleepHours: sleepHours ?? this.sleepHours,
      anxiety: anxiety ?? this.anxiety,
      irritability: irritability ?? this.irritability,
      medicationTaken: medicationTaken ?? this.medicationTaken,
      pain: pain ?? this.pain,
      stress: stress ?? this.stress,
      happenedToday: happenedToday ?? this.happenedToday,
      bestPart: bestPart ?? this.bestPart,
      hardestPart: hardestPart ?? this.hardestPart,
      gratitude: gratitude ?? this.gratitude,
      learnedToday: learnedToday ?? this.learnedToday,
      selfCareWater: selfCareWater ?? this.selfCareWater,
      selfCareFood: selfCareFood ?? this.selfCareFood,
      selfCareMedication: selfCareMedication ?? this.selfCareMedication,
      selfCareMovement: selfCareMovement ?? this.selfCareMovement,
      selfCareRest: selfCareRest ?? this.selfCareRest,
      bodyCheckIns: bodyCheckIns ?? this.bodyCheckIns,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  String get firstLine {
    final candidates = [happenedToday, bestPart, hardestPart, gratitude];
    for (final value in candidates) {
      final trimmed = value.trim();
      if (trimmed.isNotEmpty) {
        return trimmed.split('\n').first.trim();
      }
    }
    return 'Sin texto';
  }

  @override
  List<Object?> get props => [
        id,
        emotion,
        secondaryEmotions,
        intensity,
        energy,
        sleepHours,
        anxiety,
        irritability,
        medicationTaken,
        pain,
        stress,
        happenedToday,
        bestPart,
        hardestPart,
        gratitude,
        learnedToday,
        selfCareWater,
        selfCareFood,
        selfCareMedication,
        selfCareMovement,
        selfCareRest,
        bodyCheckIns,
        createdAt,
        updatedAt,
      ];
}
