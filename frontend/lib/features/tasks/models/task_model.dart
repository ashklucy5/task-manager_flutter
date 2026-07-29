import '../../../core/enums/task_priority.dart';
import '../../../core/enums/task_status.dart';

/// Maps the backend TaskResponse schema. `currency` defaults to 'USD'
/// if the backend hasn't been updated with that column yet — safe
/// either way.
class TaskModel {
  final int id;
  final String title;
  final String? description;
  final String? requirements;
  final List<Map<String, dynamic>>? requirementsChecklist;
  final String? clientName;
  final String? companyName;
  final String? imageUrl;
  final List<String>? imageUrls;
  final String category;
  final TaskPriority priority;
  final TaskStatus status;
  final String assigneeId;
  final String? assigneeName;
  final DateTime dueDate;
  final DateTime? startedAt;
  final DateTime? completedAt;
  final DateTime createdAt;
  final DateTime updatedAt;
  final double? estimatedHours;
  final double? aiPriorityScore;
  final String currency;

  const TaskModel({
    required this.id,
    required this.title,
    this.description,
    this.requirements,
    this.requirementsChecklist,
    this.clientName,
    this.companyName,
    this.imageUrl,
    this.imageUrls,
    required this.category,
    required this.priority,
    required this.status,
    required this.assigneeId,
    this.assigneeName,
    required this.dueDate,
    this.startedAt,
    this.completedAt,
    required this.createdAt,
    required this.updatedAt,
    this.estimatedHours,
    this.aiPriorityScore,
    this.currency = 'USD',
  });

  factory TaskModel.fromJson(Map<String, dynamic> json) {
    return TaskModel(
      id: json['id'] as int,
      title: json['title'] as String,
      description: json['description'] as String?,
      requirements: json['requirements'] as String?,
      requirementsChecklist: (json['requirements_checklist'] as List?)
          ?.map((e) => Map<String, dynamic>.from(e as Map))
          .toList(),
      clientName: json['client_name'] as String?,
      companyName: json['company_name'] as String?,
      imageUrl: json['image_url'] as String?,
      imageUrls: (json['image_urls'] as List?)?.map((e) => e as String).toList(),
      category: json['category'] as String,
      priority: TaskPriority.fromString(json['priority'] as String?),
      status: TaskStatus.fromString(json['status'] as String?),
      assigneeId: json['assignee_id'] as String,
      assigneeName: json['assignee_name'] as String?,
      dueDate: DateTime.parse(json['due_date'] as String),
      startedAt: json['started_at'] != null ? DateTime.parse(json['started_at'] as String) : null,
      completedAt: json['completed_at'] != null ? DateTime.parse(json['completed_at'] as String) : null,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      estimatedHours: (json['estimated_hours'] as num?)?.toDouble(),
      aiPriorityScore: (json['ai_priority_score'] as num?)?.toDouble(),
      currency: json['currency'] as String? ?? 'USD',
    );
  }
}