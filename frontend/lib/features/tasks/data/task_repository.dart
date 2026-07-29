import 'package:dio/dio.dart';
import '../../../core/network/api_endpoints.dart';
import '../../../core/network/dio_client.dart';
import '../models/task_model.dart';

class TaskRepository {
  final Dio _dio;
  TaskRepository(this._dio);

  /// GET /tasks/me — current user's own tasks.
  Future<List<TaskModel>> getMyTasks() async {
    try {
      final res = await _dio.get(ApiEndpoints.tasksMe);
      return (res.data as List).map((e) => TaskModel.fromJson(e as Map<String, dynamic>)).toList();
    } on DioException catch (e) {
      throw e.apiException;
    }
  }
  Future<void> deleteTask(int taskId) async {
    try {
      await _dio.delete(ApiEndpoints.taskById(taskId));
    } on DioException catch (e) {
      throw e.apiException;
    }
  }

  /// GET /tasks/ — filtered list. CEO sees company-wide, HR sees their
  /// team (backend enforces the actual scoping — this just passes filters).
  Future<List<TaskModel>> getTasks({
    String? assigneeId,
    String? status,
    String? priority,
    String? category,
  }) async {
    try {
      final res = await _dio.get(ApiEndpoints.tasksList, queryParameters: {
  'assignee_id': ?assigneeId,
  'status': ?status,
  'priority': ?priority,
  'category': ?category,
});
      return (res.data as List).map((e) => TaskModel.fromJson(e as Map<String, dynamic>)).toList();
    } on DioException catch (e) {
      throw e.apiException;
    }
  }

  /// GET /tasks/{id}
  Future<TaskModel> getTaskById(int taskId) async {
    try {
      final res = await _dio.get(ApiEndpoints.taskById(taskId));
      return TaskModel.fromJson(res.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw e.apiException;
    }
  }

  /// PATCH /tasks/{id}/status — quick status update (e.g. from a
  /// checkbox tap on the task list, without opening full detail).
  Future<TaskModel> updateStatus(int taskId, String status) async {
    try {
      final res = await _dio.patch(ApiEndpoints.taskStatus(taskId), data: {'status': status});
      return TaskModel.fromJson(res.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw e.apiException;
    }
  }

 Future<TaskModel> createTask({
  required String title,
  required String assigneeId,
  required DateTime dueDate,
  String? description,
  String category = 'general',
  String priority = 'medium',
  String? requirements,
  double? estimatedHours,
  double? paymentAmount,
  String currency = 'USD',
  String? clientName,
  String? companyName,
  List<MultipartFile>? images,
}) async {
  try {
    final formData = FormData.fromMap({
      'title': title,
      'assignee_id': assigneeId,
      'due_date': dueDate.toIso8601String(),
      'category': category,
      'priority': priority,
      'currency': currency,
      'description': ?description,
      'requirements': ?requirements,
      'estimated_hours': ?estimatedHours,
      'payment_amount': ?paymentAmount,
      'client_name': ?clientName,
      'company_name': ?companyName,
      if (images != null && images.isNotEmpty) 'images': images,
    });
    final res = await _dio.post(ApiEndpoints.tasksList, data: formData);
    return TaskModel.fromJson(res.data as Map<String, dynamic>);
  } on DioException catch (e) {
    throw e.apiException;
  }
}
/// PATCH /tasks/{id} - Full task update
/// PATCH /tasks/{id} - Full task update
Future<TaskModel> updateTask({
  required int taskId,
  String? title,
  String? description,
  String? assigneeId,
  DateTime? dueDate,
  String? priority,
  String? status,
  String? category,
  double? paymentAmount,
  String? currency,
  List<String>? imageUrls,        // existing images to KEEP
  List<MultipartFile>? newImages, // new images to upload
  List<String>? imagesToDelete,   // existing image urls/ids to remove
}) async {
  try {
    final hasNewImages = newImages != null && newImages.isNotEmpty;

    final dynamic data;
    if (hasNewImages) {
      // Files present → must go as multipart, JSON body can't carry MultipartFile.
      data = FormData.fromMap({
        'title': ?title,
        'description': ?description,
        'assignee_id': ?assigneeId,
        'due_date': ?dueDate?.toIso8601String(),
        'priority': ?priority,
        'status': ?status,
        'category': ?category,
        'currency': ?currency,
        if (paymentAmount != null) 'payment_amount': (paymentAmount * 100).round(),
        'images': newImages,
        'existing_image_urls': ?imageUrls,
        'images_to_delete': ?imagesToDelete,
      });
    } else {
      // No new files → plain JSON is fine, still needs to carry keep/delete lists.
      final map = <String, dynamic>{};
      if (title != null) map['title'] = title;
      if (description != null) map['description'] = description;
      if (assigneeId != null) map['assignee_id'] = assigneeId;
      if (dueDate != null) map['due_date'] = dueDate.toIso8601String();
      if (priority != null) map['priority'] = priority;
      if (status != null) map['status'] = status;
      if (category != null) map['category'] = category;
      if (paymentAmount != null) map['payment_amount'] = (paymentAmount * 100).round();
      if (currency != null) map['currency'] = currency;
      if (imageUrls != null) map['existing_image_urls'] = imageUrls;
      if (imagesToDelete != null) map['images_to_delete'] = imagesToDelete;
      data = map;
    }

    final res = await _dio.put(ApiEndpoints.taskById(taskId), data: data);
    return TaskModel.fromJson(res.data as Map<String, dynamic>);
  } on DioException catch (e) {
    throw e.apiException;
  }
}

}