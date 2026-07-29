/// Base class for every error thrown by the network layer. Repositories
/// catch DioException and rethrow one of these instead, so providers
/// and UI code never need to know Dio exists — they just catch
/// ApiException and read .message.
sealed class ApiException implements Exception {
  final String message;
  final int? statusCode;

  const ApiException(this.message, {this.statusCode});

  @override
  String toString() => message;
}

/// 401 — token missing, invalid, or expired. Repositories/providers
/// should react to this by clearing TokenStorage and routing to login.
class UnauthorizedException extends ApiException {
  const UnauthorizedException([super.message = 'Session expired. Please log in again.'])
      : super(statusCode: 401);
}

/// 403 — authenticated, but not allowed (e.g. a member hitting a
/// SuperAdmin-only financials endpoint).
class ForbiddenException extends ApiException {
  const ForbiddenException([super.message = "You don't have permission to do that."])
      : super(statusCode: 403);
}

/// 404 — resource not found (task/user deleted or wrong id).
class NotFoundException extends ApiException {
  const NotFoundException([super.message = 'Not found.']) : super(statusCode: 404);
}

/// 422 — FastAPI validation error. Carries the raw field-level errors
/// from HTTPValidationError so forms can show them per-field if wanted.
class ValidationException extends ApiException {
  final List<Map<String, dynamic>> errors;

  const ValidationException(this.errors, [super.message = 'Please check your input.'])
      : super(statusCode: 422);
}

/// 500 / other server-side failures.
class ServerException extends ApiException {
  const ServerException([super.message = 'Something went wrong on our end.', int? statusCode])
      : super(statusCode: statusCode ?? 500);
}

/// No internet, DNS failure, connection refused (e.g. backend not
/// running locally) — distinct from a server error because the fix is
/// different (check connection / check backend is running, not retry).
class NetworkException extends ApiException {
  const NetworkException([super.message = 'Could not connect. Check your connection and try again.']);
}

/// Request took too long — separate from NetworkException so the UI
/// can show a more specific "timed out" message if useful.
class TimeoutException extends ApiException {
  const TimeoutException([super.message = 'Request timed out. Please try again.']);
}

/// Catch-all for anything that doesn't map to the above.
class UnknownApiException extends ApiException {
  const UnknownApiException([super.message = 'An unexpected error occurred.']);
}