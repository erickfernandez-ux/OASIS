import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:oasis/features/wellbeing/domain/enums/mood_type.dart';
import 'package:oasis/features/wellbeing/presentation/providers/wellbeing_controller.dart';

void main() {
  test('registers medication intake', () async {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final controller = container.read(wellbeingControllerProvider.notifier);
    await controller.markMedicationTaken('med-001');
    final state = await controller.future;

    expect(state.todayMedicationLog.any((entry) => entry.medicationId == 'med-001'), isTrue);
  });

  test('registers water intake', () async {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final controller = container.read(wellbeingControllerProvider.notifier);
    await controller.registerWater(250);
    final state = await controller.future;

    expect(state.todayWaterMl, greaterThan(0));
  });

  test('registers mood entry', () async {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final controller = container.read(wellbeingControllerProvider.notifier);
    await controller.createMoodEntry(mood: MoodType.happy, note: 'Muy bien');
    final state = await controller.future;

    expect(state.moodEntries.any((entry) => entry.note == 'Muy bien'), isTrue);
  });

  test('starts and finishes pomodoro', () async {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final controller = container.read(wellbeingControllerProvider.notifier);
    await controller.startPomodoro();
    await controller.finishPomodoro();
    final state = await controller.future;

    expect(state.completedPomodoroSessions, greaterThanOrEqualTo(1));
  });
}
