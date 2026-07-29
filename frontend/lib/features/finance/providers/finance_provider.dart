import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/dio_client.dart';
import '../data/finance_repository.dart';

final financeRepositoryProvider = Provider((ref) => FinanceRepository(ref.watch(dioProvider)));

final financialSummaryProvider = FutureProvider.autoDispose((ref) {
  return ref.watch(financeRepositoryProvider).getSummary();
});

final financialTasksProvider = FutureProvider.autoDispose((ref) {
  return ref.watch(financeRepositoryProvider).getTasksWithFinancials();
});