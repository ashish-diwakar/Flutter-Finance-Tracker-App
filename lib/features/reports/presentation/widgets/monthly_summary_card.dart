import 'package:flutter/material.dart';

import '../../../../core/utils/currency_formatter.dart';

class MonthlySummaryCard
    extends StatelessWidget {

  final int income;
  final int expense;

  const MonthlySummaryCard({
    super.key,
    required this.income,
    required this.expense,
  });

  @override
  Widget build(BuildContext context) {

    final balance =
        income - expense;

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
                        income,
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
                        expense,
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
                balance,
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