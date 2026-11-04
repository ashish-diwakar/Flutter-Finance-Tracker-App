import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/utils/currency_formatter.dart';
import '../../../../shared/providers/currency_provider.dart';

class MonthlySummaryCard extends ConsumerWidget {
  final int income;
  final int expense;

  const MonthlySummaryCard({
    super.key,
    required this.income,
    required this.expense,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final balance = income - expense;

    final currency = ref.watch(currencyProvider);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),

        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,

              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Text(
                        'Income',
                        style: TextStyle(
                          color: Color(0xFF536B61),
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        CurrencyFormatter.format(
                          amount: income,
                          currency: currency,
                        ),
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.green,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Text(
                        'Expense',
                        style: TextStyle(
                          color: Color(0xFF536B61),
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        CurrencyFormatter.format(
                          amount: expense,
                          currency: currency,
                        ),
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.red,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const Divider(height: 32),

            Text(
              'Balance',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: const Color(0xFF536B61),
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),

            const SizedBox(height: 8),

            Text(
              CurrencyFormatter.format(amount: balance, currency: currency),

              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: balance >= 0 ? Colors.green : Colors.red,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
