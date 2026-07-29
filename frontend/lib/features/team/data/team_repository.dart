import 'package:dio/dio.dart';
import 'package:nexusflow_ai/core/network/dio_client.dart';
import '../../../core/network/api_endpoints.dart';

class TeamRepository {
  final Dio _dio;
  TeamRepository(this._dio);

  Future<void> removeMember(String userId) async {
    try {
      await _dio.delete(ApiEndpoints.userById(userId));
    } on DioException catch (e) {
      throw e.apiException;
    }
  }
}