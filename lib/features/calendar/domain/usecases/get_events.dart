import '../entities/event.dart';
import '../repositories/event_repository.dart';

/// Retrieves events within a specified date range.
/// If no range is provided, returns all events.
class GetEvents {
  final EventRepository _repository;

  const GetEvents(this._repository);

  Future<List<Event>> call({DateTime? start, DateTime? end}) async {
    if (start != null && end != null) {
      return _repository.getEventsInRange(start, end);
    }
    return _repository.getAllEvents();
  }
}
