import 'package:flutter_test/flutter_test.dart';
import 'package:oasis/features/habits/domain/entities/habit.dart';
import 'package:oasis/features/habits/domain/enums/habit_frequency.dart';
import 'package:oasis/features/notes/domain/entities/note.dart';

void main() {
  test('habit keeps its goal and note keeps attachments', () {
    final createdAt = DateTime(2026, 6, 30);
    final habit = Habit(
      id: 'habit-1',
      title: 'Hydration',
      frequency: HabitFrequency.daily,
      goal: 'Drink 2 liters',
      createdAt: createdAt,
    );

    final note = Note(
      id: 'note-1',
      title: 'Ideas',
      content: 'Capture the next step',
      attachments: const ['image.png'],
      createdAt: createdAt,
      updatedAt: createdAt,
    );

    expect(habit.goal, 'Drink 2 liters');
    expect(note.attachments, ['image.png']);
  });
}
