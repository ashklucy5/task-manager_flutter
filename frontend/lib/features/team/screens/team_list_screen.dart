import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/error_view.dart';
import '../../../core/widgets/loading_indicator.dart';
import '../../../core/widgets/profile_card.dart';
import '../providers/team_provider.dart';

class TeamListScreen extends ConsumerWidget {
  const TeamListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = AppColors.of(context);
    final spacing = AppSpacing.of(context);
    final groupsAsync = ref.watch(teamListProvider);

    return Scaffold(
      backgroundColor: colors.backgroundSecondary,
      appBar: AppBar(title: Text('Team', style: AppTypography.title1(context, colors.labelPrimary))),
      body: groupsAsync.when(
        loading: () => const LoadingIndicator(),
        error: (err, _) => ErrorView(message: err.toString(), onRetry: () => ref.invalidate(teamListProvider)),
        data: (groups) {
          final all = groups.expand((g) => g.members).toList();
          if (all.isEmpty) {
            return const EmptyState(icon: Icons.groups_outlined, message: 'No team members yet.');
          }
          return ListView.separated(
            padding: EdgeInsets.symmetric(horizontal: spacing.screenPadding, vertical: spacing.sm),
            itemCount: all.length,
            separatorBuilder: (_, _) => SizedBox(height: spacing.xs),
            itemBuilder: (context, index) {
              final m = all[index];
              return ProfileCard(
                fullName: m.fullName,
                position: m.position,
                role: m.role,
                status: m.status,
                avatarUrl: m.avatarUrl,
                subtitle: m.lastSeenLabel,
              );
            },
          );
        },
      ),
    );
  }
}