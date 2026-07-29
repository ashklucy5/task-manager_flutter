import 'package:dio/dio.dart';
import '../../../core/network/api_endpoints.dart';
import '../../../core/network/dio_client.dart';
import '../models/company_registration_result.dart';
import '../models/token_model.dart';
import '../models/user_model.dart';

class AuthRepository {
  final Dio _dio;
  AuthRepository(this._dio);

  Future<TokenModel> login({required String username, required String password}) async {
    try {
      final res = await _dio.post(ApiEndpoints.login, data: {
        'username': username,
        'password': password,
      });
      return TokenModel.fromJson(res.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw e.apiException;
    }
  }

  Future<TokenModel> register(Map<String, dynamic> userCreatePayload) async {
    try {
      final res = await _dio.post(ApiEndpoints.register, data: userCreatePayload);
      return TokenModel.fromJson(res.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw e.apiException;
    }
  }

  /// POST /companies/with-admin — creates a company AND its first
  /// SuperAdmin (CEO) atomically. Used by both "Company" and
  /// "Individual" registration modes; the screen decides what values
  /// to pass for companyName/companyCode/adminPosition, this method
  /// doesn't know or care which mode the user picked.
  Future<CompanyWithAdminResult> registerCompanyWithAdmin({
    required String companyName,
    required String companyCode,
    String? companyDescription,
    required String adminEmail,
    required String adminFullName,
    required String adminPassword,
    required String adminPosition,
  }) async {
    try {
      final res = await _dio.post(ApiEndpoints.companyWithAdmin, data: {
        'company': {
          'name': companyName,
          'code': companyCode,
          if (companyDescription != null && companyDescription.isNotEmpty)
            'description': companyDescription,
        },
        'admin': {
          'email': adminEmail,
          'full_name': adminFullName,
          'password': adminPassword,
          'position': adminPosition,
        },
      });
      return CompanyWithAdminResult.fromJson(res.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw e.apiException;
    }
  }

  Future<UserModel> getCurrentUser() async {
    try {
      final res = await _dio.get(ApiEndpoints.usersMe);
      return UserModel.fromJson(res.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw e.apiException;
    }
  }

  Future<void> logout() async {
    try {
      await _dio.post(ApiEndpoints.logout);
    } on DioException catch (e) {
      throw e.apiException;
    }
  }

  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      await _dio.put(ApiEndpoints.updatePassword, data: {
        'current_password': currentPassword,
        'new_password': newPassword,
      });
    } on DioException catch (e) {
      throw e.apiException;
    }
  }
}