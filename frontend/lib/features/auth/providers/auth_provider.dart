import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart' show ChangeNotifierProvider;
import 'package:nexusflow_ai/core/network/api_config.dart';
import '../../../core/enums/user_role.dart';
import '../../../core/network/api_exceptions.dart';
import '../../../core/network/dio_client.dart';
import '../../../core/storage/token_storage.dart';
import '../data/auth_repository.dart';
import '../models/company_registration_result.dart';
import '../models/user_model.dart';

enum AuthStatus { unknown, unauthenticated, authenticated }

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(ref.watch(dioProvider));
});

/// The single source of truth for auth state. Exposed as a
/// ChangeNotifier (not a plain StateNotifier) specifically so
/// GoRouter's `refreshListenable` can watch it directly.
class AuthController extends ChangeNotifier {
  final AuthRepository _repository;

  AuthStatus _status = AuthStatus.unknown;
  UserModel? _user;
  String? _errorMessage;
  bool _isLoading = false;

  AuthController(this._repository) {
    _checkStoredToken();
  }

  AuthStatus get status => _status;
  UserModel? get user => _user;
  UserRole? get role => _user?.role;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _isLoading;

  Future<void> _checkStoredToken() async {
    try {
      final hasToken = await TokenStorage.hasToken();

      if (!hasToken && ApiConfig.isDevelopment && dotenv.env['DEV_AUTO_LOGIN'] == 'true') {
        final success = await login(
          username: dotenv.env['DEV_EMAIL'] ?? '',
          password: dotenv.env['DEV_PASSWORD'] ?? '',
        );
        if (success) return;
      }

      if (!hasToken) {
        _status = AuthStatus.unauthenticated;
        notifyListeners();
        return;
      }

      _user = await _repository.getCurrentUser();
      _status = AuthStatus.authenticated;
    } catch (_) {
      _status = AuthStatus.unauthenticated;
    } finally {
      notifyListeners();
    }
  }

  Future<bool> login({required String username, required String password}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final token = await _repository.login(username: username, password: password);
      await TokenStorage.saveToken(accessToken: token.accessToken, tokenType: token.tokenType);
      _user = await _repository.getCurrentUser();
      _status = AuthStatus.authenticated;
      _isLoading = false;
      notifyListeners();
      return true;
    } on ApiException catch (e) {
      _errorMessage = e.message;
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Creates a company + its first SuperAdmin (CEO) and logs them in —
  /// the response already contains the admin user and token, so unlike
  /// login() there's no follow-up getCurrentUser() call needed.
  /// Returns the result (with company name/code) on success so the
  /// screen can show it if it wants; null on failure, with
  /// errorMessage set the same way login() does.
  Future<CompanyWithAdminResult?> registerCompany({
    required String companyName,
    required String companyCode,
    String? companyDescription,
    required String adminEmail,
    required String adminFullName,
    required String adminPassword,
    required String adminPosition,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await _repository.registerCompanyWithAdmin(
        companyName: companyName,
        companyCode: companyCode,
        companyDescription: companyDescription,
        adminEmail: adminEmail,
        adminFullName: adminFullName,
        adminPassword: adminPassword,
        adminPosition: adminPosition,
      );
      await TokenStorage.saveToken(
        accessToken: result.token.accessToken,
        tokenType: result.token.tokenType,
      );
      _user = result.admin;
      _status = AuthStatus.authenticated;
      _isLoading = false;
      notifyListeners();
      return result;
    } on ApiException catch (e) {
      _errorMessage = e.message;
      _isLoading = false;
      notifyListeners();
      return null;
    }
  }

  Future<void> logout() async {
    try {
      await _repository.logout();
    } catch (_) {
      // best-effort — clear locally regardless
    }
    await TokenStorage.clearToken();
    _user = null;
    _status = AuthStatus.unauthenticated;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}

final authControllerProvider = ChangeNotifierProvider<AuthController>((ref) {
  return AuthController(ref.watch(authRepositoryProvider));
});

final currentUserProvider = Provider<UserModel?>((ref) {
  return ref.watch(authControllerProvider).user;
});