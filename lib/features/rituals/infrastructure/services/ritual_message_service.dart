import '../../domain/entities/ritual.dart';
import '../../domain/enums/ritual_type.dart';

abstract interface class RitualMessageService {
  String titleFor(
    Ritual ritual, {
    String? preferredName,
    DateTime? now,
  });

  String bodyFor(
    Ritual ritual, {
    DateTime? now,
  });
}

class DefaultRitualMessageService implements RitualMessageService {
  const DefaultRitualMessageService();

  @override
  String titleFor(
    Ritual ritual, {
    String? preferredName,
    DateTime? now,
  }) {
    final timestamp = now ?? DateTime.now();
    final bucket = _bucket(ritual: ritual, now: timestamp);
    final name = (preferredName ?? '').trim();

    return switch (ritual.type) {
      RitualType.morning => name.isEmpty
          ? _pick(const [
              'Buenos dias 🌿',
              'Buen dia en OASIS',
              'Comenzamos suave',
            ], bucket)
          : _pick(
              [
                'Buenos dias $name 🌿',
                '$name, buen dia',
                '$name, empezamos con calma',
              ],
              bucket,
            ),
      RitualType.night => _pick(const [
          'Antes de terminar el dia...',
          'Antes de dormir...',
          'Un cierre suave para hoy',
        ], bucket),
      RitualType.journal => _pick(const [
          'Un minuto para escribir',
          'Tu journal te espera',
          'Escribir tambien cuida',
        ], bucket),
      RitualType.hydration => _pick(const [
          'Pausa de hidratacion',
          'Un vaso de agua ahora',
          'Un sorbo de cuidado',
        ], bucket),
      RitualType.movement => _pick(const [
          'Momento de moverte',
          'Una pausa corporal suave',
          'Moverse tambien ayuda',
        ], bucket),
      RitualType.agenda => _pick(const [
          'Agenda del dia',
          'Un momento para ordenar hoy',
          'Revisemos tu agenda con calma',
        ], bucket),
      RitualType.medication => _pick(const [
          'Hora de tu medicacion',
          'Recordatorio de medicacion',
          'Seguimos tu plan de cuidado',
        ], bucket),
    };
  }

  @override
  String bodyFor(
    Ritual ritual, {
    DateTime? now,
  }) {
    final timestamp = now ?? DateTime.now();
    final bucket = _bucket(ritual: ritual, now: timestamp);

    return switch (ritual.type) {
      RitualType.morning => _pick(const [
          'Como amaneciste hoy?',
          'Un dia tranquilo comienza con una respiracion.',
          'Tomemos un minuto para empezar presente.',
        ], bucket),
      RitualType.night => _pick(const [
          'Quieres escribir unas lineas?',
          'Gracias por llegar hasta aqui.',
          'Como termino tu dia?',
        ], bucket),
      RitualType.journal => _pick(const [
          'Tu yo del futuro agradecera unas lineas.',
          'Una nota breve puede aclarar mucho.',
          'Escribe lo que necesites soltar hoy.',
        ], bucket),
      RitualType.hydration => _pick(const [
          'Un poco de agua tambien es autocuidado.',
          'Te acompano con un vaso de agua?',
          'Hidratarte puede ayudarte a volver al centro.',
        ], bucket),
      RitualType.movement => _pick(const [
          'Hace un rato que no te mueves.',
          'Estirar las piernas unos minutos puede hacer bien.',
          'Mover el cuerpo tambien baja tension.',
        ], bucket),
      RitualType.agenda => _pick(const [
          'Tu dia puede sentirse mas claro con un vistazo breve.',
          'Ordenar pendientes puede bajar ruido mental.',
          'Pequenos pasos, un plan sereno.',
        ], bucket),
      RitualType.medication => _pick(const [
          'Tu cuidado diario tambien vive en estos pequenos pasos.',
          'Si ya la tomaste, puedes marcarla ahora.',
          'Seguimos con constancia, sin apuro.',
        ], bucket),
    };
  }

  static int _bucket({
    required Ritual ritual,
    required DateTime now,
  }) {
    final day = DateTime(now.year, now.month, now.day)
        .difference(DateTime(now.year, 1, 1))
        .inDays;
    return (ritual.id.hashCode + day).abs();
  }

  static String _pick(List<String> options, int bucket) {
    if (options.isEmpty) return '';
    return options[bucket % options.length];
  }
}
