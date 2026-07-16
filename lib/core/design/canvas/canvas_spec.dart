import 'package:flutter/material.dart';

enum CanvasEnvironment {
  forest,
  mist,
  linen,
  coast,
  sereneNight,
}

enum CanvasIntensity {
  verySoft,
  soft,
  medium,
}

enum CanvasMotion {
  enabled,
  reduced,
  off,
}

extension CanvasEnvironmentX on CanvasEnvironment {
  String get label => switch (this) {
        CanvasEnvironment.forest => 'Bosque',
        CanvasEnvironment.mist => 'Bruma',
        CanvasEnvironment.linen => 'Lino',
        CanvasEnvironment.coast => 'Costa',
        CanvasEnvironment.sereneNight => 'Noche Serena',
      };

  Color get primary => switch (this) {
        CanvasEnvironment.forest => const Color(0xFF91A58C),
        CanvasEnvironment.mist => const Color(0xFF6E808D),
        CanvasEnvironment.linen => const Color(0xFFC9B69D),
        CanvasEnvironment.coast => const Color(0xFF8EA2B2),
        CanvasEnvironment.sereneNight => const Color(0xFF3B3A43),
      };

  Color get secondary => switch (this) {
        CanvasEnvironment.forest => const Color(0xFFA8B48A),
        CanvasEnvironment.mist => const Color(0xFF9A95AE),
        CanvasEnvironment.linen => const Color(0xFFD9CBB6),
        CanvasEnvironment.coast => const Color(0xFFD9CCB8),
        CanvasEnvironment.sereneNight => const Color(0xFF5B5764),
      };

  Color get tertiary => switch (this) {
        CanvasEnvironment.forest => const Color(0xFFF5F1E8),
        CanvasEnvironment.mist => const Color(0xFF98A4AF),
        CanvasEnvironment.linen => const Color(0xFFF2E9D9),
        CanvasEnvironment.coast => const Color(0xFFEDEBE7),
        CanvasEnvironment.sereneNight => const Color(0xFF6A6762),
      };

  Color get ambientLight => switch (this) {
        CanvasEnvironment.forest => const Color(0xFFFFFBF3),
        CanvasEnvironment.mist => const Color(0xFFF4F5FA),
        CanvasEnvironment.linen => const Color(0xFFFFF6E8),
        CanvasEnvironment.coast => const Color(0xFFF5F8FA),
        CanvasEnvironment.sereneNight => const Color(0xFFE1D3C7),
      };
}

extension CanvasIntensityX on CanvasIntensity {
  String get label => switch (this) {
        CanvasIntensity.verySoft => 'Muy suave',
        CanvasIntensity.soft => 'Suave',
        CanvasIntensity.medium => 'Media',
      };
}

extension CanvasMotionX on CanvasMotion {
  String get label => switch (this) {
        CanvasMotion.enabled => 'Activado',
        CanvasMotion.reduced => 'Reducido',
        CanvasMotion.off => 'Sin movimiento',
      };

  Duration get cycle => switch (this) {
        CanvasMotion.enabled => const Duration(seconds: 42),
        CanvasMotion.reduced => const Duration(seconds: 56),
        CanvasMotion.off => const Duration(seconds: 60),
      };

  double get maxShift => switch (this) {
        CanvasMotion.enabled => 8,
        CanvasMotion.reduced => 4,
        CanvasMotion.off => 0,
      };
}
