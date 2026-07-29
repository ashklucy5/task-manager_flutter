import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiConfig {
  ApiConfig._();

  static String get baseUrl => dotenv.env['API_BASE_URL'] ?? 'http://127.0.0.1:8000/api';
  static int get timeoutSeconds => int.tryParse(dotenv.env['API_TIMEOUT_SECONDS'] ?? '') ?? 30;
  static bool get isDevelopment => dotenv.env['ENV'] == 'development';
}