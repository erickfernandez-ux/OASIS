import '../entities/quiet_hours.dart';
import '../entities/ritual.dart';
import '../enums/ritual_type.dart';

List<Ritual> defaultRituals() {
  return const <Ritual>[
    Ritual(
      id: 'r-morning',
      type: RitualType.morning,
      enabled: true,
      hour: 7,
      minute: 30,
      title: 'Comenzar el dia',
      description: 'Un comienzo suave para organizar tu atencion.',
    ),
    Ritual(
      id: 'r-night',
      type: RitualType.night,
      enabled: true,
      hour: 21,
      minute: 45,
      title: 'Cerrar el dia',
      description: 'Un cierre amable para bajar ritmo y descansar.',
    ),
    Ritual(
      id: 'r-journal',
      type: RitualType.journal,
      enabled: false,
      hour: 20,
      minute: 30,
      title: 'Diario',
      description: 'Un momento breve para escucharte con calma.',
    ),
    Ritual(
      id: 'r-medication',
      type: RitualType.medication,
      enabled: true,
      hour: 9,
      minute: 0,
      title: 'Medicacion',
      description: 'Recordatorio sereno para tu cuidado diario.',
    ),
    Ritual(
      id: 'r-hydration',
      type: RitualType.hydration,
      enabled: false,
      hour: 11,
      minute: 0,
      title: 'Hidratacion',
      description: 'Una pausa breve para tomar agua.',
    ),
    Ritual(
      id: 'r-movement',
      type: RitualType.movement,
      enabled: false,
      hour: 18,
      minute: 15,
      title: 'Movimiento',
      description: 'Un gesto corporal suave para soltar tension.',
    ),
  ];
}

const defaultQuietHours = QuietHours(
  enabled: true,
  startHour: 22,
  startMinute: 0,
  endHour: 7,
  endMinute: 0,
);

const defaultMedicationCriticalInQuietHours = false;

class RitualSettingsSnapshot {
  final List<Ritual> rituals;
  final QuietHours quietHours;
  final bool medicationCriticalInQuietHours;

  const RitualSettingsSnapshot({
    required this.rituals,
    required this.quietHours,
    required this.medicationCriticalInQuietHours,
  });
}

RitualSettingsSnapshot ritualSettingsFromMap(Map<String, dynamic>? data) {
  final rituals = defaultRituals();
  var quietHours = defaultQuietHours;
  var medicationCriticalInQuietHours = defaultMedicationCriticalInQuietHours;

  if (data == null) {
    return RitualSettingsSnapshot(
      rituals: rituals,
      quietHours: quietHours,
      medicationCriticalInQuietHours: medicationCriticalInQuietHours,
    );
  }

  final ritualsRaw = (data['rituals'] as List?) ?? const <dynamic>[];
  final ritualsById = {
    for (final item in ritualsRaw.whereType<Map>())
      (item['id'] as String?): item.cast<String, dynamic>(),
  };

  final hydratedRituals = rituals.map((ritual) {
    final raw = ritualsById[ritual.id];
    if (raw == null) return ritual;
    return ritual.copyWith(
      enabled: (raw['enabled'] as bool?) ?? ritual.enabled,
      hour: (raw['hour'] as int?) ?? ritual.hour,
      minute: (raw['minute'] as int?) ?? ritual.minute,
    );
  }).toList(growable: false);

  final quietRaw = data['quietHours'];
  if (quietRaw is Map) {
    final quietJson = quietRaw.cast<String, dynamic>();
    quietHours = quietHours.copyWith(
      enabled: (quietJson['enabled'] as bool?) ?? quietHours.enabled,
      startHour: (quietJson['startHour'] as int?) ?? quietHours.startHour,
      startMinute: (quietJson['startMinute'] as int?) ?? quietHours.startMinute,
      endHour: (quietJson['endHour'] as int?) ?? quietHours.endHour,
      endMinute: (quietJson['endMinute'] as int?) ?? quietHours.endMinute,
    );
  }

  medicationCriticalInQuietHours =
      (data['medicationCriticalInQuietHours'] as bool?) ??
          defaultMedicationCriticalInQuietHours;

  return RitualSettingsSnapshot(
    rituals: hydratedRituals,
    quietHours: quietHours,
    medicationCriticalInQuietHours: medicationCriticalInQuietHours,
  );
}
