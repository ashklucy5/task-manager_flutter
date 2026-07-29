import 'package:dio/dio.dart';
import 'package:nexusflow_ai/core/network/dio_client.dart';
import '../../../core/network/api_endpoints.dart';

class AnalyticsRepository {
  final Dio _dio;
  AnalyticsRepository(this._dio);

  /// Backend returns generic {} for both — shape not in OpenAPI spec,
  /// so we pass through as raw maps and read defensively in the UI.
  Future<Map<String, dynamic>> getTeamPerformance() async {
    try {
      final res = await _dio.get(ApiEndpoints.teamPerformance);
      return res.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw e.apiException;
    }
  }

  Future<Map<String, dynamic>> getWorkloadBalance() async {
    try {
      final res = await _dio.get(ApiEndpoints.workloadBalance);
      return res.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw e.apiException;
    }
  }
}