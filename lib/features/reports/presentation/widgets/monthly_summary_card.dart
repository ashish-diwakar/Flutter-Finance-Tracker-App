import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/utils/currency_formatter.dart';
import '../../../../shared/providers/currency_provider.dart';

class MonthlySummaryCard
    extends ConsumerWidget {

  final int income;
  final int expense;

  const MonthlySummaryCard({
    super.key,
    required this.income,
    required this.expense,
  });

  @override
  Widget build(
    BuildContext context,
    WidgetRef ref,
  ) {

    final balance =
        income - expense;

    final currency =
        ref.watch(
      currencyProvider,
    );

    return Card(

      child: Padding(
        padding: const EdgeInsets.all(16),

        child: Column(

          children: [

            Row(
              mainAxisAlignment:
                  MainAxisAlignment.spaceBetween,

              children: [

                Column(
                  children: [

                    const Text('Income'),

                    Text(
                      CurrencyFormatter
                          .format(
                        amount: income,
                        currency: currency,
                      ),
                    ),
                  ],
                ),

                Column(
                  children: [

                    const Text('Expense'),

                    Text(
                      CurrencyFormatter
                          .format(
                        amount: expense,
                        currency: currency,
                      ),
                    ),
                  ],
                ),
              ],
            ),

            const Divider(height: 32),

            Text(
              'Balance',
              style: Theme.of(context)
                  .textTheme
                  .titleMedium,
            ),

            const SizedBox(height: 8),

            Text(
              CurrencyFormatter.format(
                amount: balance,
                currency: currency,
              ),

              style: const TextStyle(
                fontSize: 24,
                fontWeight:
                    FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
