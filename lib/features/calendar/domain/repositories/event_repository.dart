import '../entities/event.dart';

/// Contract for Event data operations.
abstract class EventRepository {
  /// Returns all events ordered by start date.
  Future<List<Event>> getAllEvents();

  /// Returns a single event by id, or null if not found.
  Future<Event?> getEventById(String id);

  /// Returns events within the given date range.
  Future<List<Event>> getEventsInRange(DateTime start, DateTime end);

  /// Persists a new event.
  Future<Event> createEvent(Event event);

  /// Updates an existing event.
  Future<Event> updateEvent(Event event);

  /// Deletes an event by id.
  Future<bool> deleteEvent(String id);
}
