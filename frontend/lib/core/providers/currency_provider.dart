import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:intl/intl.dart';
import '../models/app_currency.dart';
import '../storage/settings_storage.dart';

/// Holds the CEO/user's currently selected DISPLAY/analysis currency —
/// this is the currency amounts get converted TO when shown in
/// dashboards/finance screens. It is separate from a task's own
/// currency (what it was actually priced in at creation).
class CurrencyController extends StateNotifier<AppCurrency> {
  CurrencyController() : super(AppCurrency.usd) {
    _load();
  }

  Future<void> _load() async {
    final code = await SettingsStorage.getCurrencyCode();
    if (code != null) {
      state = AppCurrency.fromCode(code);
    }
  }

  Future<void> setCurrency(AppCurrency currency) async {
    state = currency;
    await SettingsStorage.setCurrencyCode(currency.code);
  }
}

final currencyControllerProvider = StateNotifierProvider<CurrencyController, AppCurrency>((ref) {
  return CurrencyController();
});

/// Formats a raw cents value into a display string.
///
/// - If [currencyOverride] is given, formats using THAT currency's
///   symbol/locale (e.g. showing a task in the currency it was actually
///   priced in — EUR for a German client's task).
/// - If omitted, formats using the user's globally preferred currency
///   (from currencyControllerProvider) — e.g. the CEO's analysis view.
///
/// Use this EVERYWHERE money is shown — never format inline with '\$'.
String formatMoneyFromCents(WidgetRef ref, int? cents, {AppCurrency? currencyOverride}) {
  final AppCurrency currency = currencyOverride ?? ref.watch(currencyControllerProvider);
  final double amount = (cents ?? 0) / 100;
  final formatter = NumberFormat.currency(
    locale: currency.locale,
    symbol: currency.symbol,
  );
  return formatter.format(amount);
}