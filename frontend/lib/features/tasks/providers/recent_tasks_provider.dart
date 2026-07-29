import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'task_list_provider.dart';

/// Independent of taskFilterProvider — home dashboards always want
/// "my upcoming tasks," regardless of whatever filter the Tasks tab
/// happens to be sitting on.
final recentTasksProvider = FutureProvider.autoDispose((ref) async {
  final repository = ref.watch(taskRepositoryProvider);
  final tasks = await repository.getMyTasks();
  tasks.sort((a, b) => a.dueDate.compareTo(b.dueDate));
  return tasks.take(4).toList();
});