import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/error_view.dart';
import '../../../core/widgets/loading_indicator.dart';
import '../providers/analytics_provider.dart';

class AnalyticsScreen extends ConsumerWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = AppColors.of(context);
    final spacing = AppSpacing.of(context);
    final performanceAsync = ref.watch(teamPerformanceProvider);
    final workloadAsync = ref.watch(workloadBalanceProvider);

    return Scaffold(
      backgroundColor: colors.backgroundSecondary,
      appBar: AppBar(title: Text('Analytics', style: AppTypography.title1(context, colors.labelPrimary))),
      body: ListView(
        padding: EdgeInsets.symmetric(horizontal: spacing.screenPadding, vertical: spacing.md),
        children: [
          Text('Team Performance', style: AppTypography.title3(context, colors.labelPrimary)),
          SizedBox(height: spacing.sm),
          performanceAsync.when(
            loading: () => const LoadingIndicator(),
            error: (err, _) => ErrorView(message: err.toString(), onRetry: () => ref.invalidate(teamPerformanceProvider)),
            data: (data) => Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  data.isEmpty ? 'No performance data yet.' : data.toString(),
                  style: AppTypography.body(context, colors.labelPrimary),
                ),
              ),
            ),
          ),
          SizedBox(height: spacing.xl),

          Text('Workload Balance', style: AppTypography.title3(context, colors.labelPrimary)),
          SizedBox(height: spacing.sm),
          workloadAsync.when(
            loading: () => const LoadingIndicator(),
            error: (err, _) => ErrorView(message: err.toString(), onRetry: () => ref.invalidate(workloadBalanceProvider)),
            data: (data) => Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  data.isEmpty ? 'No workload data yet.' : data.toString(),
                  style: AppTypography.body(context, colors.labelPrimary),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}