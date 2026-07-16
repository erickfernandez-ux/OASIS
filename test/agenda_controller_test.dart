import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:oasis/features/agenda/domain/enums/task_status.dart';
import 'package:oasis/features/agenda/presentation/providers/agenda_controller.dart';

void main() {
  test('controller creates, edits, completes, deletes and filters tasks', () async {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final controller = container.read(agendaControllerProvider.notifier);

    await controller.createTask(title: 'Plan sprint', description: 'Review scope');
    final initialTasks = await controller.future;
    expect(initialTasks.any((task) => task.title == 'Plan sprint'), isTrue);

    final created = initialTasks.firstWhere((task) => task.title == 'Plan sprint');
    await controller.updateTask(id: created.id, title: 'Plan sprint review');
    final updatedTasks = await controller.future;
    final updated = updatedTasks.firstWhere((task) => task.id == created.id);
    expect(updated.title, 'Plan sprint review');

    await controller.completeTask(created.id);
    final completedTasks = await controller.future;
    final completed = completedTasks.firstWhere((task) => task.id == created.id);
    expect(completed.status, TaskStatus.completed);

    await controller.setFilter(TaskFilter.pending);
    final pendingTasks = await controller.future;
    expect(pendingTasks.every((task) => task.status != TaskStatus.completed), isTrue);

    await controller.setSearchQuery('review');
    final searchedTasks = await controller.future;
    expect(searchedTasks.any((task) => task.title.contains('review')), isFalse);

    await controller.deleteTask(created.id);
    final afterDelete = await controller.future;
    expect(afterDelete.any((task) => task.id == created.id), isFalse);
  });
}
