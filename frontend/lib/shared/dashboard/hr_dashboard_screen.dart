import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/router/app_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/section_header.dart';
import '../../core/widgets/task_card.dart';
import '../../features/auth/providers/auth_provider.dart';
import '../../features/presence/providers/team_pulse_provider.dart';
import '../../features/tasks/providers/recent_tasks_provider.dart';

class HrDashboardScreen extends ConsumerWidget {
  const HrDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = AppColors.of(context);
    final spacing = AppSpacing.of(context);
    final user = ref.watch(currentUserProvider);
    final tasksAsync = ref.watch(recentTasksProvider);
    final groupsAsync = ref.watch(teamPulseProvider);

    final myTeam = groupsAsync.maybeWhen(
      data: (groups) => groups.isNotEmpty ? groups.first.members : [],
      orElse: () => [],
    );
    final onlineCount = myTeam.where((m) => m.isOnline).length;

    return Scaffold(
      backgroundColor: colors.backgroundSecondary,
      appBar: AppBar(
        title: Text(
          user != null ? 'Good day, ${user.fullName.split(' ').first}' : 'Home',
          style: AppTypography.title1(context, colors.labelPrimary),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(recentTasksProvider);
          ref.invalidate(teamPulseProvider);
        },
        child: ListView(
          padding: EdgeInsets.symmetric(horizontal: spacing.screenPadding, vertical: spacing.md),
          children: [
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: spacing.sm,
              crossAxisSpacing: spacing.sm,
              childAspectRatio: 1.7,
              children: [
                _StatTile(label: 'My Team', value: '${myTeam.length}'),
                _StatTile(label: 'Team Online', value: '$onlineCount/${myTeam.length}', color: colors.systemGreen),
                _StatTile(
                  label: 'Tasks Assigned',
                  value: tasksAsync.maybeWhen(data: (t) => '${t.length}', orElse: () => '—'),
                ),
                _StatTile(label: 'Pending Approvals', value: '—', color: colors.systemOrange),
              ],
            ),
            SizedBox(height: spacing.xl),

            SectionHeader(title: 'Team Overview', actionLabel: 'View All', onAction: () => context.go(AppRoutes.team)),
            SizedBox(height: spacing.sm),
            SizedBox(
              height: 72,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: myTeam.length,
                separatorBuilder: (_, _) => SizedBox(width: spacing.sm),
                itemBuilder: (context, index) {
                  final m = myTeam[index];
                  return Column(
                    children: [
                      CircleAvatar(radius: 24, child: Text(m.fullName.substring(0, 1))),
                    ],
                  );
                },
              ),
            ),
            SizedBox(height: spacing.xl),

            SectionHeader(title: 'Recent Tasks', actionLabel: 'View All', onAction: () => context.go(AppRoutes.tasks)),
            SizedBox(height: spacing.sm),
            tasksAsync.when(
              loading: () => const SizedBox.shrink(),
              error: (_, _) => const SizedBox.shrink(),
              data: (tasks) => Column(
                children: tasks
                    .map((t) => Padding(
                          padding: EdgeInsets.only(bottom: spacing.cardGap),
                          child: TaskCard(
                            title: t.title,
                            assigneeName: t.assigneeName,
                            dueDate: t.dueDate,
                            status: t.status,
                            priority: t.priority,
                            onTap: () => context.push(AppRoutes.taskDetailPath(t.id)),
                          ),
                        ))
                    .toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  final String label;
  final String value;
  final Color? color;
  const _StatTile({required this.label, required this.value, this.color});

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(label, style: AppTypography.footnote(context, colors.labelSecondary)),
            const SizedBox(height: 4),
            Text(value, style: AppTypography.title2(context, color ?? colors.labelPrimary)),
          ],
        ),
      ),
    );
  }
}