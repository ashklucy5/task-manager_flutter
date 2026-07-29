import 'package:dio/dio.dart';
import 'package:nexusflow_ai/core/network/dio_client.dart';
import '../../../core/network/api_endpoints.dart';
import '../models/financial_models.dart';

class FinanceRepository {
  final Dio _dio;
  FinanceRepository(this._dio);

  Future<FinancialSummary> getSummary() async {
    try {
      final res = await _dio.get(ApiEndpoints.financialsSummary);
      return FinancialSummary.fromJson(res.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw e.apiException;
    }
  }

  Future<List<TaskWithFinancials>> getTasksWithFinancials() async {
    try {
      final res = await _dio.get(ApiEndpoints.financialsTasks);
      return (res.data as List).map((e) => TaskWithFinancials.fromJson(e as Map<String, dynamic>)).toList();
    } on DioException catch (e) {
      throw e.apiException;
    }
  }
}