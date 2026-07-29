import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/router/app_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/profile_avatar.dart';
import '../../core/widgets/section_header.dart';
import '../../core/widgets/task_card.dart';
import '../../features/auth/providers/auth_provider.dart';
import '../../features/presence/providers/team_pulse_provider.dart';
import '../../features/tasks/providers/recent_tasks_provider.dart';

class CeoDashboardScreen extends ConsumerWidget {
  const CeoDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = AppColors.of(context);
    final spacing = AppSpacing.of(context);
    final user = ref.watch(currentUserProvider);
    final tasksAsync = ref.watch(recentTasksProvider);
    final groupsAsync = ref.watch(teamPulseProvider);

    final allMembers = groupsAsync.maybeWhen(
      data: (groups) => groups.expand((g) => g.members).toList(),
      orElse: () => [],
    );
    final onlineCount = allMembers.where((m) => m.isOnline).length;

    return Scaffold(
      backgroundColor: colors.backgroundSecondary,
      appBar: AppBar(
        title: Text(_greeting(user?.fullName), style: AppTypography.title1(context, colors.labelPrimary)),
        actions: [
          IconButton(icon: const Icon(Icons.notifications_none), onPressed: () => context.push(AppRoutes.notifications)),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(recentTasksProvider);
          ref.invalidate(teamPulseProvider);
        },
        child: ListView(
          padding: EdgeInsets.symmetric(horizontal: spacing.screenPadding, vertical: spacing.md),
          children: [
  // ── Team Pulse now comes FIRST, right after the greeting ──
  SectionHeader(title: 'Team Pulse', actionLabel: 'View All', onAction: () => context.go(AppRoutes.pulse)),
  SizedBox(height: spacing.sm),
  SizedBox(
    height: 72,
    child: ListView.separated(
      scrollDirection: Axis.horizontal,
      itemCount: allMembers.length,
      separatorBuilder: (_, _) => SizedBox(width: spacing.sm),
      itemBuilder: (context, index) {
        final m = allMembers[index];
        return Column(
          children: [
            ProfileAvatar(fullName: m.fullName, status: m.status, avatarUrl: m.avatarUrl, size: 48),
          ],
        );
      },
    ),
  ),
  SizedBox(height: spacing.xl),

  // ── Then stats ──
  GridView.count(
    crossAxisCount: 2,
    shrinkWrap: true,
    physics: const NeverScrollableScrollPhysics(),
    mainAxisSpacing: spacing.sm,
    crossAxisSpacing: spacing.sm,
    childAspectRatio: 1.7,
    children: [
      _StatCard(
        label: 'Active Tasks',
        value: tasksAsync.maybeWhen(data: (t) => '${t.length}', orElse: () => '—'),
        onTap: () => context.go(AppRoutes.tasks),
      ),
      _StatCard(
        label: 'Team Online',
        value: '$onlineCount/${allMembers.length}',
        color: colors.systemGreen,
      ),
      const _StatCard(label: 'Overdue', value: '—', colorKey: _StatColorKey.red),
      const _StatCard(label: 'Revenue', value: '—', colorKey: _StatColorKey.green),
    ],
  ),
  SizedBox(height: spacing.xl),

  // ── Then recent tasks ──
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

  String _greeting(String? name) {
    final hour = DateTime.now().hour;
    final part = hour < 12 ? 'Good morning' : (hour < 17 ? 'Good afternoon' : 'Good evening');
    return name != null ? '$part, ${name.split(' ').first}' : part;
  }
}

enum _StatColorKey { none, red, green }

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final Color? color;
  final _StatColorKey colorKey;
  final VoidCallback? onTap;

  const _StatCard({
    required this.label,
    required this.value,
    this.color,
    this.colorKey = _StatColorKey.none,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final resolvedColor = color ??
        switch (colorKey) {
          _StatColorKey.red => colors.systemRed,
          _StatColorKey.green => colors.systemGreen,
          _StatColorKey.none => colors.labelPrimary,
        };

    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(label, style: AppTypography.footnote(context, colors.labelSecondary)),
              const SizedBox(height: 4),
              Text(value, style: AppTypography.title2(context, resolvedColor)),
            ],
          ),
        ),
      ),
    );
  }
}