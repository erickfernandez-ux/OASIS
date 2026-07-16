import '../repositories/event_repository.dart';

/// Permanently removes an event from the calendar.
class DeleteEvent {
  final EventRepository _repository;

  const DeleteEvent(this._repository);

  Future<bool> call(String id) async {
    return _repository.deleteEvent(id);
  }
}
