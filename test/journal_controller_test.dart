import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:oasis/features/journal/domain/entities/journal_entry.dart';
import 'package:oasis/features/journal/domain/enums/journal_emotion.dart';
import 'package:oasis/features/journal/presentation/providers/journal_controller.dart';

void main() {
  test('creates, edits, lists and deletes journal entries', () async {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final controller = container.read(journalControllerProvider.notifier);

    final created = await controller.saveEntry(
      JournalEntry(
        id: '',
        emotion: JournalEmotion.serene,
        secondaryEmotions: const ['Calma'],
        intensity: 7,
        energy: 6,
        sleepHours: 7,
        anxiety: 3,
        irritability: 2,
        medicationTaken: true,
        pain: 1,
        stress: 4,
        happenedToday: 'El día fue más lento de lo normal.',
        bestPart: 'Pude descansar un poco.',
        hardestPart: 'Costó arrancar.',
        gratitude: 'Agradezco la pausa.',
        learnedToday: 'Pedir apoyo temprano ayuda.',
        selfCareWater: true,
        selfCareFood: true,
        selfCareMedication: true,
        selfCareMovement: false,
        selfCareRest: true,
        bodyCheckIns: const ['Dormí bien', 'Tomé agua'],
        createdAt: DateTime(2026, 7, 1),
        updatedAt: DateTime(2026, 7, 1),
      ),
    );

    expect(created.id, isNotEmpty);

    final updated = await controller.saveEntry(
      created.copyWith(
        happenedToday: 'El día fue más lento y más amable.',
        emotion: JournalEmotion.grateful,
      ),
    );

    expect(updated.emotion, JournalEmotion.grateful);

    final entries = await controller.future;
    expect(entries.any((entry) => entry.id == created.id), isTrue);

    await controller.deleteEntry(created.id);
    final afterDelete = await controller.future;
    expect(afterDelete.any((entry) => entry.id == created.id), isFalse);
  });
}
