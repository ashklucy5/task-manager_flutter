import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Wraps flutter_secure_storage for everything auth-token related.
///
/// This is the ONLY place in the app that touches secure storage directly
/// — repositories/providers call these methods, never
/// FlutterSecureStorage itself. Keeps key names and storage config in
/// one place if you ever need to change how/where tokens are persisted.
class TokenStorage {
  TokenStorage._();

  static const _storage = FlutterSecureStorage();

  static const _keyAccessToken = 'nexusflow_access_token';
  static const _keyTokenType = 'nexusflow_token_type';

  /// Save the token after a successful login/register.
  static Future<void> saveToken({
    required String accessToken,
    String tokenType = 'bearer',
  }) async {
    await _storage.write(key: _keyAccessToken, value: accessToken);
    await _storage.write(key: _keyTokenType, value: tokenType);
  }

  /// Read the stored access token, or null if not logged in.
  static Future<String?> getAccessToken() {
    return _storage.read(key: _keyAccessToken);
  }

  /// Read the stored token type (usually "bearer"), defaulting sensibly.
  static Future<String> getTokenType() async {
    return await _storage.read(key: _keyTokenType) ?? 'bearer';
  }

  /// Build the full "Authorization" header value, or null if not logged in.
  static Future<String?> getAuthorizationHeader() async {
    final token = await getAccessToken();
    if (token == null || token.isEmpty) return null;
    final type = await getTokenType();
    // Capitalize scheme per HTTP convention (Bearer, not bearer)
    final scheme = type.isEmpty ? 'Bearer' : '${type[0].toUpperCase()}${type.substring(1)}';
    return '$scheme $token';
  }

  /// True if a token is currently stored (does NOT validate it against
  /// the backend — just checks presence. Expired/invalid tokens are
  /// caught by the Dio interceptor on first real request).
  static Future<bool> hasToken() async {
    final token = await getAccessToken();
    return token != null && token.isNotEmpty;
  }

  /// Clear the token on logout or when the backend returns 401.
  static Future<void> clearToken() async {
    await _storage.delete(key: _keyAccessToken);
    await _storage.delete(key: _keyTokenType);
  }
}