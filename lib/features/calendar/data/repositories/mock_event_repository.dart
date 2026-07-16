import 'package:uuid/uuid.dart';

import '../../../../core/utils/local_json_store.dart';
import '../../domain/entities/event.dart';
import '../../domain/enums/event_type.dart';
import '../../domain/repositories/event_repository.dart';

/// In-memory implementation of [EventRepository].
class MockEventRepository implements EventRepository {
  static const _storageKey = 'calendar_events';
  final List<Event> _events = [];
  final _uuid = const Uuid();
  Future<void>? _initFuture;

  MockEventRepository() {
    _seedData();
  }

  void _seedData() {
    final now = DateTime.now();
    _events.addAll([
      Event(
        id: 'sample-event-team-meeting',
        title: 'Reunión de equipo',
        description: 'Sprint planning semanal',
        startDateTime: now.add(const Duration(hours: 2)),
        endDateTime: now.add(const Duration(hours: 3)),
        location: 'Sala de conferencias A',
        type: EventType.work,
        color: '#2C3E33',
        createdAt: now.subtract(const Duration(days: 1)),
      ),
      Event(
        id: 'sample-event-medical-appointment',
        title: 'Cita médica',
        description: 'Revisión anual con el médico de cabecera',
        startDateTime: now.add(const Duration(days: 3)),
        endDateTime: now.add(const Duration(days: 3, hours: 1)),
        location: 'Centro Médico Norte',
        type: EventType.health,
        color: '#C07756',
        bufferBefore: const Duration(minutes: 30),
        createdAt: now.subtract(const Duration(days: 5)),
      ),
      Event(
        id: 'sample-event-dinner-friends',
        title: 'Cena con amigos',
        description: 'Cumpleaños de María',
        startDateTime: now.add(const Duration(days: 5, hours: 20)),
        endDateTime: now.add(const Duration(days: 5, hours: 23)),
        location: 'Restaurante El Jardín',
        type: EventType.social,
        color: '#BCAEA4',
        createdAt: now.subtract(const Duration(days: 2)),
      ),
    ]);
  }

  @override
  Future<List<Event>> getAllEvents() async {
    await _ensureInitialized();
    await _simulateNetworkDelay();
    return List.unmodifiable(_events..sort((a, b) => a.startDateTime.compareTo(b.startDateTime)));
  }

  @override
  Future<Event?> getEventById(String id) async {
    await _ensureInitialized();
    await _simulateNetworkDelay();
    try {
      return _events.firstWhere((e) => e.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<List<Event>> getEventsInRange(DateTime start, DateTime end) async {
    await _ensureInitialized();
    await _simulateNetworkDelay();
    return _events.where((e) {
      return e.startDateTime.isAfter(start) && e.startDateTime.isBefore(end) ||
          e.startDateTime.isAtSameMomentAs(start) ||
          e.startDateTime.isAtSameMomentAs(end);
    }).toList();
  }

  @override
  Future<Event> createEvent(Event event) async {
    await _ensureInitialized();
    await _simulateNetworkDelay();
    final created = event.copyWith(id: _uuid.v4());
    _events.add(created);
    await _persist();
    return created;
  }

  @override
  Future<Event> updateEvent(Event event) async {
    await _ensureInitialized();
    await _simulateNetworkDelay();
    final index = _events.indexWhere((e) => e.id == event.id);
    if (index == -1) throw Exception('Event not found: ${event.id}');
    _events[index] = event;
    await _persist();
    return event;
  }

  @override
  Future<bool> deleteEvent(String id) async {
    await _ensureInitialized();
    await _simulateNetworkDelay();
    final index = _events.indexWhere((e) => e.id == id);
    if (index == -1) return false;
    _events.removeAt(index);
    await _persist();
    return true;
  }

  Future<void> _ensureInitialized() {
    _initFuture ??= _loadFromStorage();
    return _initFuture!;
  }

  Future<void> _loadFromStorage() async {
    final raw = await LocalJsonStore.readList(_storageKey);
    if (raw == null) {
      return;
    }
    if (raw.isEmpty) {
      _events.clear();
      return;
    }

    _events
      ..clear()
      ..addAll(
        raw
            .whereType<Map>()
            .map((item) => _fromJson(item.cast<String, dynamic>())),
      );
  }

  Future<void> _persist() async {
    await LocalJsonStore.writeList(
      _storageKey,
      _events.map(_toJson).toList(growable: false),
    );
  }

  Map<String, dynamic> _toJson(Event event) {
    return {
      'id': event.id,
      'title': event.title,
      'description': event.description,
      'startDateTime': event.startDateTime.toIso8601String(),
      'endDateTime': event.endDateTime.toIso8601String(),
      'allDay': event.allDay,
      'location': event.location,
      'type': event.type.name,
      'color': event.color,
      'isRecurring': event.isRecurring,
      'recurrenceRuleId': event.recurrenceRuleId,
      'bufferBefore': event.bufferBefore?.inMinutes,
      'bufferAfter': event.bufferAfter?.inMinutes,
      'travelTime': event.travelTime?.inMinutes,
      'alertOffsets': event.alertOffsets.map((d) => d.inMinutes).toList(),
      'createdAt': event.createdAt.toIso8601String(),
    };
  }

  Event _fromJson(Map<String, dynamic> json) {
    final alertOffsets = (json['alertOffsets'] as List?)
            ?.whereType<num>()
            .map((value) => Duration(minutes: value.toInt()))
            .toList() ??
        const <Duration>[];

    return Event(
      id: (json['id'] as String?) ?? _uuid.v4(),
      title: (json['title'] as String?) ?? 'Evento',
      description: json['description'] as String?,
      startDateTime:
          DateTime.tryParse((json['startDateTime'] as String?) ?? '') ??
              DateTime.now(),
      endDateTime: DateTime.tryParse((json['endDateTime'] as String?) ?? '') ??
          DateTime.now().add(const Duration(hours: 1)),
      allDay: (json['allDay'] as bool?) ?? false,
      location: json['location'] as String?,
      type: EventType.values.firstWhere(
        (item) => item.name == json['type'],
        orElse: () => EventType.personal,
      ),
      color: json['color'] as String?,
      isRecurring: (json['isRecurring'] as bool?) ?? false,
      recurrenceRuleId: json['recurrenceRuleId'] as String?,
      bufferBefore: (json['bufferBefore'] as num?) == null
          ? null
          : Duration(minutes: (json['bufferBefore'] as num).toInt()),
      bufferAfter: (json['bufferAfter'] as num?) == null
          ? null
          : Duration(minutes: (json['bufferAfter'] as num).toInt()),
      travelTime: (json['travelTime'] as num?) == null
          ? null
          : Duration(minutes: (json['travelTime'] as num).toInt()),
      alertOffsets: alertOffsets,
      createdAt: DateTime.tryParse((json['createdAt'] as String?) ?? '') ??
          DateTime.now(),
    );
  }

  Future<void> _simulateNetworkDelay() async {
    await Future.delayed(const Duration(milliseconds: 150));
  }
}
