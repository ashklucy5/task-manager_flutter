import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/currency_provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/error_view.dart';
import '../../../core/widgets/loading_indicator.dart';
import '../providers/finance_provider.dart';

class FinanceDashboardScreen extends ConsumerWidget {
  const FinanceDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = AppColors.of(context);
    final spacing = AppSpacing.of(context);
    final summaryAsync = ref.watch(financialSummaryProvider);
    final tasksAsync = ref.watch(financialTasksProvider);

    return Scaffold(
      backgroundColor: colors.backgroundSecondary,
      appBar: AppBar(title: Text('Finance', style: AppTypography.title1(context, colors.labelPrimary))),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(financialSummaryProvider);
          ref.invalidate(financialTasksProvider);
        },
        child: ListView(
          padding: EdgeInsets.symmetric(horizontal: spacing.screenPadding, vertical: spacing.md),
          children: [
            summaryAsync.when(
              loading: () => const LoadingIndicator(),
              error: (err, _) => ErrorView(message: err.toString(), onRetry: () => ref.invalidate(financialSummaryProvider)),
              data: (summary) => GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: spacing.sm,
                crossAxisSpacing: spacing.sm,
                childAspectRatio: 1.7,
                children: [
                  _FinanceStatCard(
                    label: 'Total Payments',
                    value: formatMoneyFromCents(ref, summary.totalPaymentCents),
                    color: colors.systemGreen,
                  ),
                  _FinanceStatCard(
                    label: 'Completion Rate',
                    value: '${summary.completionRate.toStringAsFixed(0)}%',
                    color: colors.systemBlue,
                  ),
                  _FinanceStatCard(label: 'Total Tasks', value: '${summary.totalTasks}', color: colors.labelPrimary),
                  _FinanceStatCard(
                    label: 'Active Users',
                    value: '${summary.activeUsers}/${summary.totalUsers}',
                    color: colors.systemOrange,
                  ),
                ],
              ),
            ),
            SizedBox(height: spacing.xl),

            Text('Transactions', style: AppTypography.title3(context, colors.labelPrimary)),
            SizedBox(height: spacing.sm),
            tasksAsync.when(
              loading: () => const LoadingIndicator(),
              error: (err, _) => ErrorView(message: err.toString(), onRetry: () => ref.invalidate(financialTasksProvider)),
              data: (tasks) {
                final withAmount = tasks.where((t) => t.paymentAmount != null).toList();
                if (withAmount.isEmpty) {
                  return Text('No transactions yet.', style: AppTypography.subhead(context, colors.labelSecondary));
                }
                return Column(
                  children: withAmount
                      .map((t) => Card(
                            child: ListTile(
                              title: Text(t.title, style: AppTypography.body(context, colors.labelPrimary)),
                              subtitle: Text(t.clientName ?? '—', style: AppTypography.footnote(context, colors.labelSecondary)),
                              trailing: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    formatMoneyFromCents(ref, t.paymentAmount),
                                    style: AppTypography.body(context, t.isPaid ? colors.systemGreen : colors.systemOrange)
                                        .copyWith(fontWeight: FontWeight.w600),
                                  ),
                                  Text(t.isPaid ? 'Paid' : 'Pending', style: AppTypography.caption1(context, colors.labelSecondary)),
                                ],
                              ),
                            ),
                          ))
                      .toList(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _FinanceStatCard extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  const _FinanceStatCard({required this.label, required this.value, required this.color});

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
            Text(value, style: AppTypography.title2(context, color)),
          ],
        ),
      ),
    );
  }
}