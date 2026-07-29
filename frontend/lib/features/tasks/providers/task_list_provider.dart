import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../../../core/enums/task_priority.dart';
import '../../../core/enums/task_status.dart';
import '../../../core/network/dio_client.dart';
import '../data/task_repository.dart';
import '../models/task_model.dart';

final taskRepositoryProvider = Provider<TaskRepository>((ref) {
  return TaskRepository(ref.watch(dioProvider));
});

/// Which tab/filter is currently selected on the task list screen.
enum TaskFilter { all, myTasks, highPriority, overdue, completed }

final taskFilterProvider = StateProvider<TaskFilter>((ref) => TaskFilter.all);

/// The actual task list, refetched whenever the filter changes.
/// autoDispose so it doesn't linger in memory once the screen is left.
final taskListProvider = FutureProvider.autoDispose<List<TaskModel>>((ref) async {
  final filter = ref.watch(taskFilterProvider);
  final repository = ref.watch(taskRepositoryProvider);

  switch (filter) {
    case TaskFilter.all:
      return repository.getTasks();
    case TaskFilter.myTasks:
      return repository.getMyTasks();
    case TaskFilter.highPriority:
      final tasks = await repository.getTasks();
      return tasks
          .where((t) => t.priority == TaskPriority.high || t.priority == TaskPriority.urgent)
          .toList();
    case TaskFilter.overdue:
      return repository.getTasks(status: TaskStatus.overdue.value);
    case TaskFilter.completed:
      return repository.getTasks(status: TaskStatus.completed.value);
  }
});