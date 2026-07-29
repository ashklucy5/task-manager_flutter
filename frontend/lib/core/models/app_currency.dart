/// A supported display currency. No exchange-rate conversion happens
/// here — this only changes how amounts are *formatted* (symbol,
/// decimal style, locale). The underlying cents value from the backend
/// is unchanged; conversion (when needed) is handled separately by
/// exchange_rate_provider.dart.
class AppCurrency {
  final String code;       // ISO 4217, e.g. "USD"
  final String symbol;     // e.g. "$"
  final String name;       // e.g. "US Dollar"
  final String locale;     // for intl NumberFormat, e.g. "en_US"

  const AppCurrency({
    required this.code,
    required this.symbol,
    required this.name,
    required this.locale,
  });

  static const usd = AppCurrency(code: 'USD', symbol: '\$', name: 'US Dollar', locale: 'en_US');
  static const eur = AppCurrency(code: 'EUR', symbol: '€', name: 'Euro', locale: 'de_DE');
  static const gbp = AppCurrency(code: 'GBP', symbol: '£', name: 'British Pound', locale: 'en_GB');
  static const inr = AppCurrency(code: 'INR', symbol: '₹', name: 'Indian Rupee', locale: 'en_IN');
  static const jpy = AppCurrency(code: 'JPY', symbol: '¥', name: 'Japanese Yen', locale: 'ja_JP');
  static const cny = AppCurrency(code: 'CNY', symbol: '¥', name: 'Chinese Yuan', locale: 'zh_CN');
  static const sgd = AppCurrency(code: 'SGD', symbol: 'S\$', name: 'Singapore Dollar', locale: 'en_SG');
  static const aud = AppCurrency(code: 'AUD', symbol: 'A\$', name: 'Australian Dollar', locale: 'en_AU');

  static const all = [usd, eur, gbp, inr, jpy, cny, sgd, aud];

  static AppCurrency fromCode(String? code) {
    return all.firstWhere((c) => c.code == code, orElse: () => usd);
  }

  @override
  bool operator ==(Object other) => other is AppCurrency && other.code == code;

  @override
  int get hashCode => code.hashCode;
}