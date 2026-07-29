import 'package:flutter/material.dart';
import '../enums/task_priority.dart';
import '../enums/task_status.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';
import 'priority_badge.dart';

class TaskCard extends StatelessWidget {
  final String title;
  final String? assigneeName;
  final DateTime dueDate;
  final TaskStatus status;
  final TaskPriority priority;
  final VoidCallback? onTap;

  const TaskCard({
    super.key, required this.title, required this.dueDate,
    required this.status, required this.priority, this.assigneeName, this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final spacing = AppSpacing.of(context);
    final isOverdue = status == TaskStatus.overdue;

    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: EdgeInsets.all(spacing.md + spacing.xs),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: Text(title, style: AppTypography.headline(context, colors.labelPrimary))),
                  SizedBox(width: spacing.xs),
                  PriorityBadge(priority: priority),
                ],
              ),
              SizedBox(height: spacing.xs),
              Row(
                children: [
                  if (assigneeName != null)
                    Text(assigneeName!, style: AppTypography.footnote(context, colors.labelSecondary)),
                  const Spacer(),
                  Text(
                    _formatDue(dueDate, isOverdue),
                    style: AppTypography.footnote(context, isOverdue ? colors.systemRed : colors.labelSecondary),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDue(DateTime date, bool overdue) {
    final now = DateTime.now();
    final diff = date.difference(now);
    if (overdue) return 'Overdue';
    if (diff.inDays == 0) return 'Due today';
    if (diff.inDays == 1) return 'Due tomorrow';
    return 'Due ${date.day}/${date.month}';
  }
}