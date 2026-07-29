import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/enums/task_status.dart';
import '../../../core/router/app_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/error_view.dart';
import '../../../core/widgets/loading_indicator.dart';
import '../../../core/widgets/priority_badge.dart';
import '../../../core/widgets/status_badge.dart';
import '../models/task_model.dart';
import '../providers/task_detail_provider.dart';
import '../../presence/providers/team_pulse_provider.dart';

class TaskDetailScreen extends ConsumerWidget {
  final int taskId;
  const TaskDetailScreen({super.key, required this.taskId});

  @override
Widget build(BuildContext context, WidgetRef ref) {
  final colors = AppColors.of(context);
  final taskAsync = ref.watch(taskDetailProvider(taskId));
  final teamAsync = ref.watch(teamPulseProvider);   // ← add this

  return Scaffold(
    backgroundColor: colors.backgroundSecondary,
    appBar: AppBar(
      title: taskAsync.maybeWhen(
        data: (task) => Text(
          task.title,
          style: AppTypography.headline(context, colors.labelPrimary),
          overflow: TextOverflow.ellipsis,
        ),
        orElse: () => const SizedBox.shrink(),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.edit_outlined),
          onPressed: () => context.push(AppRoutes.editTaskPath(taskId)),
        ),
      ],
    ),
    body: taskAsync.when(
      loading: () => const LoadingIndicator(),
      error: (err, _) => ErrorView(
        message: err.toString(),
        onRetry: () => ref.invalidate(taskDetailProvider(taskId)),
      ),
      data: (task) {
        // Resolve assignee name from team roster if backend didn't send one
        String? resolvedName = task.assigneeName;
        if ((resolvedName == null || resolvedName.isEmpty)) {
          final groups = teamAsync.asData?.value;
          if (groups != null) {
            final allMembers = groups.expand((g) => g.members);
            for (final m in allMembers) {
              if (m.id == task.assigneeId) {
                resolvedName = m.fullName;
                break;
              }
            }
          }
        }
        return _TaskDetailBody(task: task, resolvedAssigneeName: resolvedName);
      },
    ),
    bottomNavigationBar: taskAsync.maybeWhen(
      data: (task) => _FooterActions(task: task),
      orElse: () => null,
    ),
  );
}
}

class _TaskDetailBody extends StatelessWidget {
  final TaskModel task;
  final String? resolvedAssigneeName;
  const _TaskDetailBody({required this.task, this.resolvedAssigneeName});

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final spacing = AppSpacing.of(context);

    return ListView(
      padding: EdgeInsets.symmetric(horizontal: spacing.screenPadding, vertical: spacing.md),
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            StatusBadge(status: task.status),
            SizedBox(width: spacing.xs),
            PriorityBadge(priority: task.priority),
          ],
        ),
        SizedBox(height: spacing.md),

        // Assignee card
        Card(
          child: Padding(
            padding: EdgeInsets.all(spacing.md),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: colors.fillQuaternary,
                  child: Text(
                    (resolvedAssigneeName ?? '?').substring(0, 1).toUpperCase(),
                    style: TextStyle(color: colors.labelPrimary, fontWeight: FontWeight.w600),
                  ),
                ),
                SizedBox(width: spacing.sm),
                Expanded(
                  child: Text(
                    resolvedAssigneeName ?? 'Unassigned',
                    style: AppTypography.body(context, colors.labelPrimary),
                  ),
                ),
                Text(
                  _dueLabel(task.dueDate, task.status),
                  style: AppTypography.footnote(
                    context,
                    task.status == TaskStatus.overdue ? colors.systemRed : colors.labelSecondary,
                  ),
                ),
              ],
            ),
          ),
        ),
        SizedBox(height: spacing.xl),

        if (task.description != null) ...[
          Text('Description', style: AppTypography.title3(context, colors.labelPrimary)),
          SizedBox(height: spacing.xs),
          Text(task.description!, style: AppTypography.body(context, colors.labelSecondary)),
          SizedBox(height: spacing.xl),
        ],

        if (task.requirementsChecklist != null && task.requirementsChecklist!.isNotEmpty) ...[
          Text('Checklist', style: AppTypography.title3(context, colors.labelPrimary)),
          SizedBox(height: spacing.xs),
          ...task.requirementsChecklist!.map((item) {
            final done = item['completed'] == true || item['done'] == true;
            final label = item['text'] ?? item['label'] ?? '';
            return Padding(
              padding: EdgeInsets.symmetric(vertical: spacing.xs / 2),
              child: Row(
                children: [
                  Icon(
                    done ? Icons.check_box : Icons.check_box_outline_blank,
                    color: done ? colors.systemGreen : colors.labelTertiary,
                    size: 22,
                  ),
                  SizedBox(width: spacing.sm),
                  Expanded(
                    child: Text(
                      label.toString(),
                      style: AppTypography.body(context, colors.labelPrimary).copyWith(
                        decoration: done ? TextDecoration.lineThrough : null,
                        color: done ? colors.labelTertiary : colors.labelPrimary,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
          SizedBox(height: spacing.xl),
        ],

        if (task.imageUrls != null && task.imageUrls!.isNotEmpty) ...[
          Text('Images', style: AppTypography.title3(context, colors.labelPrimary)),
          SizedBox(height: spacing.xs),
          SizedBox(
            height: 96,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: task.imageUrls!.length,
              separatorBuilder: (_, _) => SizedBox(width: spacing.xs),
              itemBuilder: (context, index) => ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(task.imageUrls![index], width: 96, height: 96, fit: BoxFit.cover),
              ),
            ),
          ),
          SizedBox(height: spacing.xl),
        ],

        if (task.clientName != null || task.companyName != null) ...[
          Text('Customer Info', style: AppTypography.title3(context, colors.labelPrimary)),
          SizedBox(height: spacing.xs),
          if (task.clientName != null) _InfoRow(label: 'Name', value: task.clientName!),
          if (task.companyName != null) _InfoRow(label: 'Company', value: task.companyName!),
          SizedBox(height: spacing.xl),
        ],
      ],
    );
  }

  String _dueLabel(DateTime date, TaskStatus status) {
    if (status == TaskStatus.overdue) return 'Overdue';
    final diff = date.difference(DateTime.now()).inDays;
    if (diff == 0) return 'Due today';
    if (diff == 1) return 'Due tomorrow';
    return 'Due ${date.day}/${date.month}';
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final spacing = AppSpacing.of(context);
    return Padding(
      padding: EdgeInsets.symmetric(vertical: spacing.xs / 2),
      child: Row(
        children: [
          SizedBox(
            width: 90,
            child: Text(label, style: AppTypography.footnote(context, colors.labelSecondary)),
          ),
          Expanded(child: Text(value, style: AppTypography.body(context, colors.labelPrimary))),
        ],
      ),
    );
  }
}

class _FooterActions extends ConsumerWidget {
  final TaskModel task;
  const _FooterActions({required this.task});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = AppColors.of(context);
    final spacing = AppSpacing.of(context);
    final controller = ref.read(taskDetailControllerProvider);

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.all(spacing.md),
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () => _showStatusPicker(context, ref, controller, task),
                child: const Text('Update Status'),
              ),
            ),
            SizedBox(width: spacing.xs),
            Expanded(
              child: ElevatedButton(
                onPressed: task.status == TaskStatus.completed
                    ? null
                    : () async {
                        await controller.updateStatus(task.id, TaskStatus.completed.value);
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Marked as complete')),
                          );
                        }
                      },
                style: ElevatedButton.styleFrom(backgroundColor: colors.systemGreen),
                child: const Text('Complete'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showStatusPicker(
    BuildContext context,
    WidgetRef ref,
    TaskDetailController controller,
    TaskModel task,
  ) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: TaskStatus.values.map((status) {
            return ListTile(
              title: Text(status.displayLabel),
              trailing: task.status == status ? const Icon(Icons.check) : null,
              onTap: () async {
                Navigator.pop(context);
                await controller.updateStatus(task.id, status.value);
              },
            );
          }).toList(),
        ),
      ),
    );
  }
}