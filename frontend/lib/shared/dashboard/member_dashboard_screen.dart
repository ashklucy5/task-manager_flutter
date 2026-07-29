import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/enums/task_status.dart';
import '../../core/router/app_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/profile_avatar.dart';
import '../../core/widgets/section_header.dart';
import '../../features/auth/providers/auth_provider.dart';
import '../../features/presence/providers/team_pulse_provider.dart';
import '../../features/tasks/providers/recent_tasks_provider.dart';

class MemberDashboardScreen extends ConsumerWidget {
  const MemberDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = AppColors.of(context);
    final spacing = AppSpacing.of(context);
    final user = ref.watch(currentUserProvider);
    final tasksAsync = ref.watch(recentTasksProvider);
    final groupsAsync = ref.watch(teamPulseProvider);

    // Member's teamPulseProvider result is already scoped to peers only
    // (same parent_id, excluding self) — see the role-branch logic in
    // team_pulse_provider.dart's UserRole.member case.
    final peers = groupsAsync.maybeWhen(
      data: (groups) => groups.isNotEmpty ? groups.first.members : <dynamic>[],
      orElse: () => <dynamic>[],
    );

    return Scaffold(
      backgroundColor: colors.backgroundSecondary,
      appBar: AppBar(
        title: Text(
          user != null ? 'Hi, ${user.fullName.split(' ').first}' : 'Home',
          style: AppTypography.title1(context, colors.labelPrimary),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(recentTasksProvider);
          ref.invalidate(teamPulseProvider);
        },
        child: tasksAsync.when(
          loading: () => const SizedBox.shrink(),
          error: (_, _) => const SizedBox.shrink(),
          data: (tasks) {
            final inProgress = tasks.where((t) => t.status == TaskStatus.inProgress).length;
            final completedToday = tasks
                .where((t) => t.status == TaskStatus.completed && t.completedAt != null && _isToday(t.completedAt!))
                .length;
            final overdue = tasks.where((t) => t.status == TaskStatus.overdue).length;

            return ListView(
              padding: EdgeInsets.symmetric(horizontal: spacing.screenPadding, vertical: spacing.md),
              children: [
                // ── Team Pulse (peers only) — right after the greeting ──
                if (peers.isNotEmpty) ...[
                  SectionHeader(title: 'Team', actionLabel: 'View All', onAction: () => context.go(AppRoutes.pulse)),
                  SizedBox(height: spacing.sm),
                  SizedBox(
                    height: 72,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: peers.length,
                      separatorBuilder: (_, _) => SizedBox(width: spacing.sm),
                      itemBuilder: (context, index) {
                        final m = peers[index];
                        return ProfileAvatar(fullName: m.fullName, status: m.status, avatarUrl: m.avatarUrl, size: 48);
                      },
                    ),
                  ),
                  SizedBox(height: spacing.xl),
                ],

                // ── Personal stats ──
                GridView.count(
                  crossAxisCount: 4,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  mainAxisSpacing: spacing.xs,
                  crossAxisSpacing: spacing.xs,
                  childAspectRatio: 0.9,
                  children: [
                    _MiniStat(label: 'My Tasks', value: '${tasks.length}'),
                    _MiniStat(label: 'In Progress', value: '$inProgress', color: colors.systemOrange),
                    _MiniStat(label: 'Done Today', value: '$completedToday', color: colors.systemGreen),
                    _MiniStat(label: 'Overdue', value: '$overdue', color: colors.systemRed),
                  ],
                ),
                SizedBox(height: spacing.xl),

                SectionHeader(title: "Today's Tasks", actionLabel: 'View All', onAction: () => context.go(AppRoutes.tasks)),
                SizedBox(height: spacing.sm),
                SizedBox(
                  height: 110,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: tasks.length,
                    separatorBuilder: (_, _) => SizedBox(width: spacing.sm),
                    itemBuilder: (context, index) {
                      final t = tasks[index];
                      return SizedBox(
                        width: 160,
                        child: Card(
                          child: InkWell(
                            onTap: () => context.push(AppRoutes.taskDetailPath(t.id)),
                            borderRadius: BorderRadius.circular(16),
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Icon(Icons.task_alt, color: colors.brandPrimary),
                                  const Spacer(),
                                  Text(
                                    t.title,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: AppTypography.footnote(context, colors.labelPrimary),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year && date.month == now.month && date.day == now.day;
  }
}

class _MiniStat extends StatelessWidget {
  final String label;
  final String value;
  final Color? color;
  const _MiniStat({required this.label, required this.value, this.color});

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(value, style: AppTypography.title3(context, color ?? colors.labelPrimary)),
            const SizedBox(height: 2),
            Text(label, textAlign: TextAlign.center, style: AppTypography.caption2(context, colors.labelSecondary)),
          ],
        ),
      ),
    );
  }
}