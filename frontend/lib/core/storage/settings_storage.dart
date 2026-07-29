import 'package:shared_preferences/shared_preferences.dart';

/// Non-sensitive local preferences — currency, theme, etc. Kept
/// separate from TokenStorage (flutter_secure_storage), which is
/// reserved specifically for the auth token.
class SettingsStorage {
  SettingsStorage._();

  static const _keyCurrencyCode = 'nexusflow_currency_code';

  static Future<String?> getCurrencyCode() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyCurrencyCode);
  }

  static Future<void> setCurrencyCode(String code) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyCurrencyCode, code);
  }
}