/// Visual canvas style used to shape the ambient atmosphere.
enum CanvasStylePreference {
  forest,
  linen,
  coast,
  mist,
  sereneNight,
}

extension CanvasStylePreferenceX on CanvasStylePreference {
  String get label => switch (this) {
        CanvasStylePreference.forest => 'Bosque',
        CanvasStylePreference.mist => 'Bruma',
        CanvasStylePreference.linen => 'Lino',
        CanvasStylePreference.coast => 'Costa',
        CanvasStylePreference.sereneNight => 'Noche Serena',
      };
}
