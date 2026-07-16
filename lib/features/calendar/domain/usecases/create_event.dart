import '../entities/event.dart';
import '../repositories/event_repository.dart';

/// Creates a new calendar event with the given time range.
class CreateEvent {
  final EventRepository _repository;

  const CreateEvent(this._repository);

  Future<Event> call({
    required String title,
    String? description,
    required DateTime startDateTime,
    required DateTime endDateTime,
    bool allDay = false,
    String? location,
    String? color,
  }) async {
    final event = Event(
      id: '', // Assigned by repository
      title: title,
      description: description,
      startDateTime: startDateTime,
      endDateTime: endDateTime,
      allDay: allDay,
      location: location,
      color: color,
      createdAt: DateTime.now(),
    );
    return _repository.createEvent(event);
  }
}
