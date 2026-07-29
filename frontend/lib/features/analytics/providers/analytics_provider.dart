import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/dio_client.dart';
import '../data/analytics_repository.dart';

final analyticsRepositoryProvider = Provider((ref) => AnalyticsRepository(ref.watch(dioProvider)));

final teamPerformanceProvider = FutureProvider.autoDispose((ref) {
  return ref.watch(analyticsRepositoryProvider).getTeamPerformance();
});

final workloadBalanceProvider = FutureProvider.autoDispose((ref) {
  return ref.watch(analyticsRepositoryProvider).getWorkloadBalance();
});