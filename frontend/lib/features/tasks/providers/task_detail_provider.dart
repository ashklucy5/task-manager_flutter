import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/task_repository.dart';
import '../models/task_model.dart';
import 'task_list_provider.dart';

/// Fetches a single task by id. Family provider so each task detail
/// screen gets its own cached instance, keyed by taskId. autoDispose
/// clears it from memory once the screen is left.
final taskDetailProvider = FutureProvider.autoDispose.family<TaskModel, int>((ref, taskId) async {
  final repository = ref.watch(taskRepositoryProvider);
  return repository.getTaskById(taskId);
});

/// Handles actions taken FROM the detail screen (status change, etc.) —
/// kept separate from the read-only fetch above so mutations don't
/// tangle with FutureProvider's caching.
class TaskDetailController {
  final TaskRepository _repository;
  final Ref _ref;

  TaskDetailController(this._repository, this._ref);

  /// Updates status, then invalidates both the detail provider (this
  /// task) and the list provider (so task_list_screen reflects the
  /// change when the user navigates back).
  Future<void> updateStatus(int taskId, String newStatus) async {
    await _repository.updateStatus(taskId, newStatus);
    _ref.invalidate(taskDetailProvider(taskId));
    _ref.invalidate(taskListProvider);
  }
}

final taskDetailControllerProvider = Provider.autoDispose<TaskDetailController>((ref) {
  return TaskDetailController(ref.watch(taskRepositoryProvider), ref);
});