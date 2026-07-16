import 'package:flutter_test/flutter_test.dart';
import 'package:oasis/features/agenda/domain/entities/task.dart';
import 'package:oasis/features/agenda/domain/repositories/task_repository.dart';
import 'package:oasis/features/agenda/domain/usecases/create_task.dart';
import 'package:oasis/features/notes/domain/entities/note.dart';
import 'package:oasis/features/notes/domain/repositories/note_repository.dart';
import 'package:oasis/features/notes/domain/usecases/create_note.dart';
import 'package:oasis/features/wellbeing/domain/usecases/get_daily_water.dart';
import 'package:oasis/features/wellbeing/domain/usecases/register_water_intake.dart';

class FakeTaskRepository implements TaskRepository {
  @override
  Future<Task> createTask(Task task) async => task.copyWith(id: 'task-1');

  @override
  Future<bool> deleteTask(String id) async => true;

  @override
  Future<List<Task>> getAllTasks() async => [];

  @override
  Future<Task?> getTaskById(String id) async => null;

  @override
  Future<List<Task>> getTasksByStatus(String status) async => [];

  @override
  Future<List<Task>> getTasksDueBefore(DateTime date) async => [];

  @override
  Future<Task> updateTask(Task task) async => task;

  @override
  Future<List<Task>> getTasksByTag(String tag) async => [];
}

class FakeNoteRepository implements NoteRepository {
  @override
  Future<Note> createNote(Note note) async => note.copyWith(id: 'note-1');

  @override
  Future<bool> deleteNote(String id) async => true;

  @override
  Future<List<Note>> getAllNotes() async => [];

  @override
  Future<List<Note>> getFavoriteNotes() async => [];

  @override
  Future<Note?> getNoteById(String id) async => null;

  @override
  Future<List<Note>> getNotesByTag(String tag) async => [];

  @override
  Future<Note> updateNote(Note note) async => note;
}

void main() {
  test('CreateTask builds a task with title, due date and default status', () async {
    final useCase = CreateTask(FakeTaskRepository());
    final dueDate = DateTime(2026, 6, 30);

    final task = await useCase(title: 'Prepare sprint review', dueDate: dueDate);

    expect(task.title, 'Prepare sprint review');
    expect(task.dueDate, dueDate);
    expect(task.status.name, 'pending');
  });

  test('CreateNote preserves attachments and content', () async {
    final useCase = CreateNote(FakeNoteRepository());

    final note = await useCase(
      title: 'Ideas',
      content: 'Capture the next step',
      attachments: const ['image.png'],
    );

    expect(note.content, 'Capture the next step');
    expect(note.attachments, ['image.png']);
  });

  test('RegisterWaterIntake and GetDailyWater calculate totals for one day', () {
    const register = RegisterWaterIntake();
    const getDailyWater = GetDailyWater();
    final today = DateTime(2026, 6, 30);
    final entry = register.call(amountMl: 250, date: today);

    final total = getDailyWater.call([entry], today);

    expect(total, 250);
  });
}
