/// How strongly the living canvas should express itself.
enum CanvasIntensityPreference {
  verySubtle,
  subtle,
  medium,
}

extension CanvasIntensityPreferenceX on CanvasIntensityPreference {
  String get label => switch (this) {
        CanvasIntensityPreference.verySubtle => 'Muy sutil',
        CanvasIntensityPreference.subtle => 'Sutil',
        CanvasIntensityPreference.medium => 'Media',
      };
}
