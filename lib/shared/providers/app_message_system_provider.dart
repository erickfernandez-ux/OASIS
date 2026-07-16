import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

@immutable
class GreetingMessage {
  const GreetingMessage({
    required this.title,
    required this.subtitle,
  });

  final String title;
  final String subtitle;
}

enum AppEmptyMessageKey {
  agendaTasks,
  agendaEvents,
  agendaReminders,
  homeUpcomingTasks,
}

enum OasisPhraseGroup {
  calm,
  motivation,
  rest,
  reflection,
  gratitude,
}

class AppMessageSystem {
  const AppMessageSystem();

  static const Map<OasisPhraseGroup, List<String>> _phrasesByGroup = {
    OasisPhraseGroup.calm: [
      'Respira despacio, estas en un lugar seguro.',
      'Un paso sereno tambien es avance.',
      'Tu ritmo de hoy es suficiente.',
      'No necesitas correr para sostenerte.',
      'La calma tambien construye.',
      'Volver al presente ya es cuidarte.',
      'Hazlo simple, hazlo amable.',
      'Puedes empezar suave.',
      'Hay espacio para bajar el volumen.',
      'Tu paz tambien merece prioridad.',
    ],
    OasisPhraseGroup.motivation: [
      'Empieza pequeno y constante.',
      'Hoy puedes avanzar una cosa a la vez.',
      'La constancia tranquila transforma.',
      'Tu esfuerzo de hoy cuenta.',
      'Cada accion amable suma.',
      'Con calma tambien se llega lejos.',
      'Tu progreso no necesita ruido.',
      'Un inicio corto abre el camino.',
      'Haz lo posible, eso ya importa.',
      'Lo pequeno repetido se vuelve grande.',
    ],
    OasisPhraseGroup.rest: [
      'Descansar tambien es parte del plan.',
      'Tu energia merece pausas reales.',
      'Parar un momento te devuelve claridad.',
      'Un respiro puede cambiar el dia.',
      'Dormir mejor tambien es cuidarte.',
      'No todo tiene que resolverse hoy.',
      'Bajar el ritmo tambien es avanzar.',
      'Tu cuerpo agradece la pausa.',
      'Una pausa consciente vale mucho.',
      'Regalarte descanso es una decision sabia.',
    ],
    OasisPhraseGroup.reflection: [
      'Escucharte con honestidad trae orden.',
      'Lo que nombras se vuelve mas claro.',
      'Hoy tambien puedes aprender de ti.',
      'Tu historia merece ser escuchada.',
      'Mirar adentro tambien es progreso.',
      'Escribir te ayuda a ver con calma.',
      'Un minuto de reflexion cambia el tono del dia.',
      'Lo importante tambien vive en lo pequeno.',
      'Tu voz interior importa.',
      'Entenderte es una forma de cuidarte.',
    ],
    OasisPhraseGroup.gratitude: [
      'Agradecer tambien sostiene.',
      'Hay belleza en lo cotidiano.',
      'Lo simple de hoy tambien merece valor.',
      'Gracias por volver a este espacio.',
      'Cada gesto amable deja huella.',
      'Hoy tambien hubo algo bueno.',
      'Reconocer lo bueno cambia la mirada.',
      'Tu camino tambien tiene luz.',
      'La gratitud trae perspectiva.',
      'Celebrar lo pequeno fortalece.',
    ],
  };

  GreetingMessage greetingFor({
    required DateTime now,
    required String preferredName,
  }) {
    final name = preferredName.trim();
    final suffix = name.isEmpty ? '' : ', $name';
    final subtitle = phraseForDay(
      group: _groupForGreeting(now),
      now: now,
    );

    if (_isMorning(now)) {
      return GreetingMessage(
        title: '🌅 Buenos días$suffix.',
        subtitle: subtitle,
      );
    }

    if (_isAfternoon(now)) {
      return GreetingMessage(
        title: '☀ Buenas tardes$suffix.',
        subtitle: subtitle,
      );
    }

    return GreetingMessage(
      title: '🌙 Buenas noches$suffix.',
      subtitle: subtitle,
    );
  }

  String phraseForDay({
    required OasisPhraseGroup group,
    required DateTime now,
  }) {
    final phrases = _phrasesByGroup[group] ?? const <String>[];
    if (phrases.isEmpty) {
      return 'Un paso sereno tambien cuenta.';
    }

    final daySeed = now.year * 10000 + now.month * 100 + now.day;
    return phrases[daySeed % phrases.length];
  }

  String contextualHomePhrase({
    required DateTime now,
    required int pendingTasksCount,
    required bool journalUsedYesterday,
  }) {
    if (_isNight(now)) {
      return phraseForDay(group: OasisPhraseGroup.rest, now: now);
    }

    if (pendingTasksCount == 0) {
      return phraseForDay(group: OasisPhraseGroup.calm, now: now);
    }

    if (journalUsedYesterday) {
      return phraseForDay(group: OasisPhraseGroup.gratitude, now: now);
    }

    return phraseForDay(group: OasisPhraseGroup.motivation, now: now);
  }

  String dailyMessageFor(DateTime now) {
    const groups = OasisPhraseGroup.values;
    final daySeed = now.year * 10000 + now.month * 100 + now.day;
    final group = groups[daySeed % groups.length];
    return phraseForDay(group: group, now: now);
  }

  String calmMessageFor(DateTime now) {
    if (_isNight(now)) {
      return phraseForDay(group: OasisPhraseGroup.rest, now: now);
    }
    return phraseForDay(group: OasisPhraseGroup.calm, now: now);
  }

  String emptyStateFor(AppEmptyMessageKey key) {
    return switch (key) {
      AppEmptyMessageKey.agendaTasks =>
        'Hoy tienes un poco mas de espacio para respirar.',
      AppEmptyMessageKey.agendaEvents =>
        'Hoy tienes un poco mas de espacio para respirar.',
      AppEmptyMessageKey.agendaReminders =>
        'Hoy tienes un poco mas de espacio para respirar.',
      AppEmptyMessageKey.homeUpcomingTasks =>
        'Hoy tienes un poco mas de espacio para respirar.',
    };
  }

  bool _isMorning(DateTime now) => now.hour >= 5 && now.hour < 12;
  bool _isAfternoon(DateTime now) => now.hour >= 12 && now.hour < 19;
  bool _isNight(DateTime now) => !_isMorning(now) && !_isAfternoon(now);

  OasisPhraseGroup _groupForGreeting(DateTime now) {
    if (_isMorning(now)) {
      return OasisPhraseGroup.motivation;
    }
    if (_isAfternoon(now)) {
      return OasisPhraseGroup.reflection;
    }
    return OasisPhraseGroup.rest;
  }
}

final appMessageSystemProvider = Provider<AppMessageSystem>((ref) {
  return const AppMessageSystem();
});
