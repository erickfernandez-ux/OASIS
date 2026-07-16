import '../entities/event.dart';
import '../repositories/event_repository.dart';

/// Updates an existing event.
class UpdateEvent {
  final EventRepository _repository;

  const UpdateEvent(this._repository);

  Future<Event> call(Event event) async {
    return _repository.updateEvent(event);
  }
}
