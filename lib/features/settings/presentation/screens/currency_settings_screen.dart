import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/supported_currencies.dart';
import '../../../../shared/providers/currency_provider.dart';

class CurrencySettingsScreen
    extends ConsumerWidget {

  const CurrencySettingsScreen({
    super.key,
  });

  @override
  Widget build(
    BuildContext context,
    WidgetRef ref,
  ) {

    final selectedCurrency =
        ref.watch(
      currencyProvider,
    );

    return Scaffold(

      appBar: AppBar(

        title: const Text(
          'Select Currency',
        ),
      ),

      body: ListView.separated(

        padding:
            const EdgeInsets.all(
          16,
        ),

        itemCount:
            supportedCurrencies.length,

        separatorBuilder:
            (_, __) =>
                const SizedBox(
          height: 12,
        ),

        itemBuilder:
            (context, index) {

          final currency =
              supportedCurrencies[
                  index];

          final isSelected =

              currency.code ==
                  selectedCurrency
                      .code;

          return Card(

            elevation:
                isSelected
                    ? 3
                    : 0,

            child: ListTile(

              contentPadding:
                  const EdgeInsets.symmetric(

                horizontal: 16,
                vertical: 8,
              ),

              leading: Text(

                currency.flag,

                style:
                    const TextStyle(

                  fontSize: 28,
                ),
              ),

              title: Text(

                currency.code,

                style:
                    const TextStyle(

                  fontWeight:
                      FontWeight.bold,
                ),
              ),

              subtitle: Text(
                currency.name,
              ),

              trailing:

                  isSelected

                      ? const Icon(

                          Icons.check_circle,

                          color:
                              Colors.green,
                        )

                      : Text(

                          currency.symbol,

                          style:
                              const TextStyle(

                            fontSize: 18,

                            fontWeight:
                                FontWeight.bold,
                          ),
                        ),

              onTap: () {

                ref
                    .read(
                  currencyProvider
                      .notifier,
                )
                    .updateCurrency(
                  currency,
                );

                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(

                  SnackBar(

                    content: Text(

                      '${currency.code} selected',
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}