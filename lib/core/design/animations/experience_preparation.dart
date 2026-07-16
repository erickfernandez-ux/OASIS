/// OASIS EXPERIENCE 16 preparation registry.
///
/// This file documents integration points only.
/// No runtime haptic or audio playback is implemented here.
class ExperiencePreparation {
  const ExperiencePreparation._();

  /// Future haptic integration points.
  static const List<String> hapticPoints = <String>[
    'journal.save',
    'agenda.task.complete',
    'wellbeing.water.register',
    'wellbeing.medication.markTaken',
    'notes.save',
    'wellbeing.pomodoro.finished',
  ];

  /// Future sound cues.
  static const List<String> soundCues = <String>[
    'save',
    'water',
    'pomodoro',
    'breathing',
    'journal',
  ];

  /// Future onboarding choreography.
  static const List<String> onboardingFlow = <String>[
    'logo',
    'fade',
    'welcome',
    'preferred_name',
    'choose_shelter',
    'enter_oasis',
  ];
}
