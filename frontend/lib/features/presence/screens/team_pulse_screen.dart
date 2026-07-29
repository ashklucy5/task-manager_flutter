import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/error_view.dart';
import '../../../core/widgets/loading_indicator.dart';
import '../../../core/widgets/profile_card.dart';
import '../providers/team_pulse_provider.dart';

class TeamPulseScreen extends ConsumerWidget {
  const TeamPulseScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = AppColors.of(context);
    final spacing = AppSpacing.of(context);
    final groupsAsync = ref.watch(teamPulseProvider);

    return Scaffold(
      backgroundColor: colors.backgroundSecondary,
      appBar: AppBar(
        title: Text('Team Pulse', style: AppTypography.title1(context, colors.labelPrimary)),
      ),
      body: groupsAsync.when(
        loading: () => const LoadingIndicator(),
        error: (err, _) => ErrorView(
          message: err.toString(),
          onRetry: () => ref.invalidate(teamPulseProvider),
        ),
        data: (groups) {
          final totalMembers = groups.fold<int>(0, (sum, g) => sum + g.members.length);
          if (totalMembers == 0) {
            return const EmptyState(icon: Icons.groups_outlined, message: 'No teammates yet.');
          }

          return RefreshIndicator(
            onRefresh: () async => ref.invalidate(teamPulseProvider),
            child: ListView.builder(
              padding: EdgeInsets.symmetric(vertical: spacing.sm),
              itemCount: groups.length,
              itemBuilder: (context, index) {
                final group = groups[index];
                if (group.members.isEmpty) return const SizedBox.shrink();

                return Padding(
                  padding: EdgeInsets.only(bottom: spacing.groupedSectionGap),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (group.manager != null || groups.length > 1) ...[
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: spacing.screenPadding),
                          child: Text(
                            group.title.toUpperCase(),
                            style: AppTypography.caption1(context, colors.labelSecondary)
                                .copyWith(fontWeight: FontWeight.w600, letterSpacing: 0.4),
                          ),
                        ),
                        SizedBox(height: spacing.xs),
                      ],
                      ...group.members.map((member) => Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: spacing.screenPadding,
                              vertical: spacing.xs / 2,
                            ),
                            child: ProfileCard(
                              fullName: member.fullName,
                              position: member.position,
                              role: member.role,
                              status: member.status,
                              avatarUrl: member.avatarUrl,
                              subtitle: member.lastSeenLabel,
                            ),
                          )),
                    ],
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}