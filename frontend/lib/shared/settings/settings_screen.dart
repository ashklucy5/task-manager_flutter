import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/models/app_currency.dart';
import '../../core/providers/currency_provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = AppColors.of(context);
    final currentCurrency = ref.watch(currencyControllerProvider);

    return Scaffold(
      backgroundColor: colors.backgroundSecondary,
      appBar: AppBar(title: Text('Settings', style: AppTypography.title1(context, colors.labelPrimary))),
      body: ListView(
        children: [
          const ListTile(title: Text('Appearance'), trailing: Icon(Icons.chevron_right)),
          const Divider(height: 1),
          ListTile(
            title: const Text('Currency'),
            subtitle: Text('${currentCurrency.name} (${currentCurrency.code})'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _showCurrencyPicker(context, ref),
          ),
          const Divider(height: 1),
          const ListTile(title: Text('Language'), trailing: Icon(Icons.chevron_right)),
          const Divider(height: 1),
          const ListTile(title: Text('About'), trailing: Icon(Icons.chevron_right)),
        ],
      ),
    );
  }

  void _showCurrencyPicker(BuildContext context, WidgetRef ref) {
    final current = ref.read(currencyControllerProvider);
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: ListView(
          shrinkWrap: true,
          children: AppCurrency.all.map((currency) {
            return ListTile(
              title: Text('${currency.name} (${currency.symbol})'),
              trailing: current.code == currency.code ? const Icon(Icons.check) : null,
              onTap: () {
                ref.read(currencyControllerProvider.notifier).setCurrency(currency);
                Navigator.pop(context);
              },
            );
          }).toList(),
        ),
      ),
    );
  }
}