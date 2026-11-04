import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/supported_currencies.dart';
import '../../../../core/widgets/aurora_app_bar.dart';
import '../../../../shared/providers/currency_provider.dart';

class CurrencySettingsScreen extends ConsumerWidget {
  const CurrencySettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedCurrency = ref.watch(currencyProvider);

    return Scaffold(
      appBar: const AuroraAppBar(title: Text('Select Currency')),
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: [Color(0xFFB6D7CC), Color(0xFFDAEDE5), Color(0xFFF8FCFA)],
            stops: [0.0, 0.52, 1.0],
          ),
        ),
        child: ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: supportedCurrencies.length,
          separatorBuilder: (_, _) => const SizedBox(height: 10),
          itemBuilder: (context, index) {
            final currency = supportedCurrencies[index];
            final isSelected = currency.code == selectedCurrency.code;

            return Card(
              margin: EdgeInsets.zero,
              color: isSelected
                  ? const Color(0xFFE0F3E7)
                  : const Color(0xFFF2F9F3),
              surfaceTintColor: Colors.transparent,
              elevation: isSelected ? 1 : 0,
              clipBehavior: Clip.antiAlias,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(
                  color: isSelected
                      ? const Color(0xFF3B9073)
                      : const Color(0xFFBCD9CC),
                  width: isSelected ? 2 : 1,
                ),
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                leading: Text(
                  currency.flag,
                  style: const TextStyle(fontSize: 28),
                ),
                title: Text(
                  currency.code,
                  style: const TextStyle(
                    color: Color(0xFF244D40),
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                subtitle: Text(
                  currency.name,
                  style: const TextStyle(
                    color: Color(0xFF58766A),
                    fontSize: 15,
                  ),
                ),
                trailing: isSelected
                    ? const CircleAvatar(
                        radius: 14,
                        backgroundColor: Color(0xFF17664F),
                        child: Icon(Icons.check, color: Colors.white, size: 18),
                      )
                    : Text(
                        currency.symbol,
                        style: const TextStyle(
                          color: Color(0xFF244D40),
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                onTap: () {
                  ref.read(currencyProvider.notifier).updateCurrency(currency);

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('${currency.code} selected')),
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }
}
