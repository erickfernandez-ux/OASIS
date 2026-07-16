enum RitualType {
  morning,
  night,
  journal,
  hydration,
  medication,
  movement,
  agenda,
}

extension RitualTypeX on RitualType {
  String get label => switch (this) {
        RitualType.morning => 'Comenzar el dia',
        RitualType.night => 'Cerrar el dia',
        RitualType.journal => 'Journal',
        RitualType.hydration => 'Hidratacion',
        RitualType.medication => 'Medicacion',
        RitualType.movement => 'Movimiento',
        RitualType.agenda => 'Agenda',
      };
}
