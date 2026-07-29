import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/app_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/error_view.dart';
import '../../../core/widgets/loading_indicator.dart';
import '../../../core/widgets/task_card.dart';
import '../providers/task_list_provider.dart';

class TaskListScreen extends ConsumerWidget {
  const TaskListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = AppColors.of(context);
    final spacing = AppSpacing.of(context);
    final tasksAsync = ref.watch(taskListProvider);
    final currentFilter = ref.watch(taskFilterProvider);

    return Scaffold(
      backgroundColor: colors.backgroundSecondary,
      appBar: AppBar(
        title: Text('Tasks', style: AppTypography.title1(context, colors.labelPrimary)),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => context.push(AppRoutes.createTask),
          ),
        ],
      ),
      body: Column(
        children: [
          SizedBox(
            height: 40,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.symmetric(horizontal: spacing.screenPadding),
              itemCount: TaskFilter.values.length,
              separatorBuilder: (_, _) => SizedBox(width: spacing.xs),
              itemBuilder: (context, index) {
                final filter = TaskFilter.values[index];
                final isSelected = filter == currentFilter;
                return ChoiceChip(
                  label: Text(_filterLabel(filter)),
                  selected: isSelected,
                  onSelected: (_) => ref.read(taskFilterProvider.notifier).state = filter,
                  labelStyle: AppTypography.footnote(
                    context,
                    isSelected ? Colors.white : colors.labelPrimary,
                  ),
                  selectedColor: colors.brandPrimary,
                  backgroundColor: colors.backgroundGrouped,
                  side: BorderSide(color: colors.separator),
                );
              },
            ),
          ),
          SizedBox(height: spacing.sm),
          Expanded(
            child: tasksAsync.when(
              loading: () => const LoadingIndicator(),
              error: (err, _) => ErrorView(
                message: err.toString(),
                onRetry: () => ref.invalidate(taskListProvider),
              ),
              data: (tasks) {
                if (tasks.isEmpty) {
                  return const EmptyState(
                    icon: Icons.check_circle_outline,
                    message: 'No tasks here.',
                  );
                }
                return RefreshIndicator(
                  onRefresh: () async => ref.invalidate(taskListProvider),
                  child: ListView.separated(
                    padding: EdgeInsets.symmetric(horizontal: spacing.screenPadding, vertical: spacing.sm),
                    itemCount: tasks.length,
                    separatorBuilder: (_, _) => SizedBox(height: spacing.cardGap),
                    itemBuilder: (context, index) {
                      final task = tasks[index];
                      return TaskCard(
                        title: task.title,
                        assigneeName: task.assigneeName,
                        dueDate: task.dueDate,
                        status: task.status,
                        priority: task.priority,
                        onTap: () => context.push(AppRoutes.taskDetailPath(task.id)),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  String _filterLabel(TaskFilter filter) {
    switch (filter) {
      case TaskFilter.all:
        return 'All';
      case TaskFilter.myTasks:
        return 'My Tasks';
      case TaskFilter.highPriority:
        return 'High Priority';
      case TaskFilter.overdue:
        return 'Overdue';
      case TaskFilter.completed:
        return 'Completed';
    }
  }
}