import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/api_exceptions.dart';
import '../../auth/providers/auth_provider.dart';

class ChangePasswordController {
  final Ref _ref;
  ChangePasswordController(this._ref);

  /// Returns null on success, or an error message on failure.
  Future<String?> submit({required String currentPassword, required String newPassword}) async {
    try {
      await _ref.read(authRepositoryProvider).changePassword(
            currentPassword: currentPassword,
            newPassword: newPassword,
          );
      return null;
    } on ApiException catch (e) {
      return e.message;
    } catch (_) {
      return 'Something went wrong. Please try again.';
    }
  }
}

final changePasswordControllerProvider = Provider.autoDispose((ref) => ChangePasswordController(ref));