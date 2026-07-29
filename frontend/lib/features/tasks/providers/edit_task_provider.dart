import 'package:dio/dio.dart' show MultipartFile;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/task_repository.dart';
import '../models/task_model.dart';
import 'task_detail_provider.dart';
import 'task_list_provider.dart';

class EditTaskController {
  final TaskRepository _repository;
  final Ref _ref;

  EditTaskController(this._repository, this._ref);

  Future<TaskModel> updateTask({
    required int taskId,
    String? title,
    String? description,
    String? assigneeId,
    DateTime? dueDate,
    String? priority,
    String? status,
    List<String>? imageUrls,
    List<MultipartFile>? newImages,
    List<String>? imagesToDelete,
  }) async {
    final task = await _repository.updateTask(
      taskId: taskId,
      title: title,
      description: description,
      assigneeId: assigneeId,
      dueDate: dueDate,
      priority: priority,
      status: status,
      imageUrls: imageUrls,
      newImages: newImages,
      imagesToDelete: imagesToDelete,
    );
    
    if (_ref.mounted) {
      _ref.invalidate(taskListProvider);
      _ref.invalidate(taskDetailProvider(taskId));
    }
    
    return task;
  }

  /// DELETE /tasks/{id}
  Future<void> deleteTask(int taskId) async {
    await _repository.deleteTask(taskId);
    if (_ref.mounted) {
      _ref.invalidate(taskListProvider);
    }
  }
}

final editTaskControllerProvider = Provider.autoDispose<EditTaskController>((ref) {
  return EditTaskController(ref.watch(taskRepositoryProvider), ref);
});