import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../presence/providers/team_pulse_provider.dart';
import 'task_list_provider.dart';

final assignableMembersProvider = FutureProvider.autoDispose((ref) async {
  final groups = await ref.watch(teamPulseProvider.future);
  return groups.expand((g) => g.members).toList();
});

class CreateTaskController {
  final Ref _ref;
  CreateTaskController(this._ref);

  Future<bool> submit({
    required String title,
    required String assigneeId,
    required DateTime dueDate,
    String? description,
    required String priority,
    String category = 'general',
    double? paymentAmount,
    String currency = 'USD',
    List<MultipartFile>? images,
  }) async {
    try {
      await _ref.read(taskRepositoryProvider).createTask(
            title: title,
            assigneeId: assigneeId,
            dueDate: dueDate,
            description: description,
            priority: priority,
            category: category,
            paymentAmount: paymentAmount,
            currency: currency,
            images: images,
          );
      _ref.invalidate(taskListProvider);
      return true;
    } catch (_) {
      return false;
    }
  }
}

final createTaskControllerProvider = Provider.autoDispose((ref) => CreateTaskController(ref));