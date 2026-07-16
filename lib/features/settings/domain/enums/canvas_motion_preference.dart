/// How much movement the living canvas should use.
enum CanvasMotionPreference {
  enabled,
  reduced,
  off,
}

extension CanvasMotionPreferenceX on CanvasMotionPreference {
  String get label => switch (this) {
        CanvasMotionPreference.enabled => 'Activado',
        CanvasMotionPreference.reduced => 'Reducido',
        CanvasMotionPreference.off => 'Sin movimiento',
      };
}
