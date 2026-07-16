import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:oasis/features/calendar/presentation/providers/calendar_controller.dart';

void main() {
  test('creates an event and adds it to the timeline', () async {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final controller = container.read(calendarControllerProvider.notifier);
    final baseState = await controller.future;

    final now = DateTime.now();
    final start = DateTime(now.year, now.month, now.day, 10, 0, 0, 0);
    final end = start.add(const Duration(hours: 1));

    await controller.createEvent(
      title: 'Revisión de sprint',
      startDateTime: start,
      endDateTime: end,
      description: 'Checklist',
    );

    final updatedState = await controller.future;
    expect(updatedState.events.any((event) => event.title == 'Revisión de sprint'), isTrue);
    expect(
      updatedState.timelineItemsForSelectedDay().any((item) => item.title == 'Revisión de sprint'),
      isTrue,
    );
    expect(baseState.selectedDay.day, updatedState.selectedDay.day);
  });

  test('edits an existing event', () async {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final controller = container.read(calendarControllerProvider.notifier);
    final now = DateTime.now();
    final start = DateTime(now.year, now.month, now.day, 15, 0, 0, 0);
    final end = start.add(const Duration(hours: 1));

    await controller.createEvent(title: 'Taller', startDateTime: start, endDateTime: end);
    final createdState = await controller.future;
    final created = createdState.events.firstWhere((event) => event.title == 'Taller');

    await controller.updateEvent(
      id: created.id,
      title: 'Taller actualizado',
      description: 'Nueva nota',
    );

    final updatedState = await controller.future;
    final edited = updatedState.events.firstWhere((event) => event.id == created.id);

    expect(edited.title, 'Taller actualizado');
    expect(edited.description, 'Nueva nota');
  });

  test('deletes an event', () async {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final controller = container.read(calendarControllerProvider.notifier);
    final now = DateTime.now();
    final start = DateTime(now.year, now.month, now.day, 18, 0, 0, 0);
    final end = start.add(const Duration(hours: 1));

    await controller.createEvent(title: 'Cena', startDateTime: start, endDateTime: end);
    final createdState = await controller.future;
    final created = createdState.events.firstWhere((event) => event.title == 'Cena');

    await controller.deleteEvent(created.id);
    final updatedState = await controller.future;

    expect(updatedState.events.any((event) => event.id == created.id), isFalse);
  });

  test('changes the selected day and refreshes the timeline', () async {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final controller = container.read(calendarControllerProvider.notifier);
    final targetDay = DateTime.now().add(const Duration(days: 3));

    await controller.setSelectedDay(targetDay);
    final state = await controller.future;

    expect(state.selectedDay.year, targetDay.year);
    expect(state.selectedDay.month, targetDay.month);
    expect(state.selectedDay.day, targetDay.day);
  });

  test('builds a daily timeline from events, tasks and medications', () async {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final controller = container.read(calendarControllerProvider.notifier);
    final state = await controller.future;

    final timeline = state.timelineItemsForSelectedDay();

    expect(timeline, isNotEmpty);
    expect(timeline.every((item) => item.time.isAfter(DateTime(1970))), isTrue);
  });
}
