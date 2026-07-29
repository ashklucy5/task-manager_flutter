import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../storage/token_storage.dart';
import 'api_config.dart';
import 'api_exceptions.dart';

/// Riverpod provider exposing a fully configured Dio instance. Every
/// repository in the app should get its Dio via `ref.watch(dioProvider)`
/// — never instantiate Dio directly anywhere else.
final dioProvider = Provider<Dio>((ref) {
  final dio = Dio(
    BaseOptions(
      baseUrl: ApiConfig.baseUrl,
      connectTimeout: Duration(seconds: ApiConfig.timeoutSeconds),
      receiveTimeout: Duration(seconds: ApiConfig.timeoutSeconds),
      headers: {'Accept': 'application/json'},
    ),
  );

  dio.interceptors.add(_AuthInterceptor());
  dio.interceptors.add(_ErrorInterceptor());

  if (ApiConfig.isDevelopment) {
    dio.interceptors.add(
      LogInterceptor(requestBody: true, responseBody: true, error: true),
    );
  }

  return dio;
});

/// Attaches the stored bearer token to every outgoing request, if present.
/// Login/register requests don't need a token yet, but attaching a null
/// header is harmless — the backend just ignores missing auth on public
/// routes.
class _AuthInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    final authHeader = await TokenStorage.getAuthorizationHeader();
    if (authHeader != null) {
      options.headers['Authorization'] = authHeader;
    }
    handler.next(options);
  }
}

/// Converts every DioException into one of our typed ApiException
/// subclasses, so repositories/providers never need to know Dio exists.
/// Also clears the stored token on 401, so the next auth check routes
/// the user back to login automatically.
class _ErrorInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    final mapped = _mapError(err);

    if (mapped is UnauthorizedException) {
      await TokenStorage.clearToken();
    }

    handler.reject(
      DioException(
        requestOptions: err.requestOptions,
        error: mapped,
        response: err.response,
        type: err.type,
      ),
    );
  }

  ApiException _mapError(DioException err) {
    switch (err.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.transformTimeout:
      case DioExceptionType.receiveTimeout:
        return const TimeoutException();

      case DioExceptionType.connectionError:
        return const NetworkException();

      case DioExceptionType.badResponse:
        return _mapStatusCode(err);

      case DioExceptionType.cancel:
        return const UnknownApiException('Request was cancelled.');

      case DioExceptionType.badCertificate:
      case DioExceptionType.unknown:
        return const NetworkException();
    }
  }

  ApiException _mapStatusCode(DioException err) {
    final status = err.response?.statusCode;
    final data = err.response?.data;

    switch (status) {
      case 401:
        return const UnauthorizedException();
      case 403:
        return const ForbiddenException();
      case 404:
        return const NotFoundException();
      case 422:
        final detail = (data is Map && data['detail'] is List)
            ? List<Map<String, dynamic>>.from(data['detail'])
            : <Map<String, dynamic>>[];
        return ValidationException(detail, _firstValidationMessage(detail));
      default:
        if (status != null && status >= 500) {
          return ServerException('Server error. Please try again later.', status);
        }
        return const UnknownApiException();
    }
  }

  String _firstValidationMessage(List<Map<String, dynamic>> errors) {
    if (errors.isEmpty) return 'Please check your input.';
    final first = errors.first;
    final loc = (first['loc'] as List?)?.join(' ') ?? '';
    final msg = first['msg'] ?? 'Invalid value';
    return loc.isEmpty ? msg.toString() : '$loc: $msg';
  }
}

/// Helper so repositories can pull the typed ApiException back out of
/// a caught DioException without re-checking types everywhere:
///
/// try {
///   await dio.get(...);
/// } on DioException catch (e) {
///   throw e.apiException;
/// }
extension DioExceptionX on DioException {
  ApiException get apiException {
    final err = error;
    return err is ApiException ? err : const UnknownApiException();
  }
}