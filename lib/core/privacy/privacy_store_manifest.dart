class PrivacyStoreManifest {
  PrivacyStoreManifest._();

  static const String journalKey = 'journal_entries';
  static const String notesKey = 'notes';
  static const String settingsKey = 'settings';
  static const String medicationsKey = 'medications';
  static const String safetyPlanKey = 'safety_plan';
  static const String wellbeingStateKey = 'wellbeing_state';
  static const String agendaTasksKey = 'tasks';
  static const String calendarEventsKey = 'calendar_events';
  static const String ritualsStateKey = 'rituals_state';

  static const Set<String> encryptedKeys = <String>{
    journalKey,
    notesKey,
    settingsKey,
    medicationsKey,
    safetyPlanKey,
    wellbeingStateKey,
  };

  static const Map<String, String> storageLabels = <String, String>{
    journalKey: 'Journal',
    notesKey: 'Notas',
    settingsKey: 'Configuración',
    medicationsKey: 'Medicación',
    safetyPlanKey: 'Plan de seguridad',
    wellbeingStateKey: 'Bienestar',
    agendaTasksKey: 'Agenda',
    calendarEventsKey: 'Calendario',
    ritualsStateKey: 'Rituales',
  };

  static const List<String> backupKeys = <String>[
    journalKey,
    notesKey,
    settingsKey,
    medicationsKey,
    safetyPlanKey,
    wellbeingStateKey,
    agendaTasksKey,
    calendarEventsKey,
    ritualsStateKey,
  ];

  static bool isSensitiveKey(String key) => encryptedKeys.contains(key);
}
