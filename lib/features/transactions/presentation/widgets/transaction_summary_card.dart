import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/utils/currency_formatter.dart';
import '../../../../shared/providers/currency_provider.dart';
import '../providers/transaction_summary_provider.dart';

class TransactionSummaryCard extends ConsumerWidget {
  const TransactionSummaryCard({
    super.key,
  });

  @override
  Widget build(
    BuildContext context,
    WidgetRef ref,
  ) {
    
    final currency =
        ref.watch(
      currencyProvider,
    );
    final summaryAsync = ref.watch(
      transactionSummaryProvider,
    );

    return summaryAsync.when(
      loading: () => const Card(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Center(
            child: CircularProgressIndicator(),
          ),
        ),
      ),

      error: (error, stack) => Card(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Text(
            'Unable to calculate summary.',
            style: TextStyle(
              color: Theme.of(context).colorScheme.error,
            ),
          ),
        ),
      ),

      data: (summary) {
        return Card(
          margin: const EdgeInsets.symmetric(
            horizontal: 12,
          ),
          elevation: 1,
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 18,
            ),
            child: Row(
              children: [
                Expanded(
                  child: _SummaryItem(
                    title: 'Income',
                    value: CurrencyFormatter.format(
                      amount: summary.income,
                      currency: currency,
                    ),
                    icon: Icons.arrow_downward,
                    color: Colors.green,
                  ),
                ),

                Container(
                  height: 50,
                  width: 1,
                  color: Colors.grey.shade300,
                ),

                Expanded(
                  child: _SummaryItem(
                    title: 'Expense',
                    value: CurrencyFormatter.format(
                      amount: summary.expense,
                      currency: currency,
                    ),
                    icon: Icons.arrow_upward,
                    color: Colors.red,
                  ),
                ),

                Container(
                  height: 50,
                  width: 1,
                  color: Colors.grey.shade300,
                ),

                Expanded(
                  child: _SummaryItem(
                    title: 'Balance',
                    value: CurrencyFormatter.format(
                      amount: summary.balance,
                      currency: currency,
                    ),
                    icon: Icons.account_balance_wallet,
                    color: summary.balance >= 0
                        ? Colors.blue
                        : Colors.orange,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _SummaryItem extends StatelessWidget {
  const _SummaryItem({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  final String title;

  final String value;

  final IconData icon;

  final Color color;

  @override
  Widget build(
    BuildContext context,
  ) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        CircleAvatar(
          radius: 18,
          backgroundColor: color.withOpacity(0.12),
          child: Icon(
            icon,
            color: color,
            size: 20,
          ),
        ),

        const SizedBox(
          height: 8,
        ),

        Text(
          title,
          style: const TextStyle(
            fontSize: 13,
            color: Colors.grey,
          ),
        ),

        const SizedBox(
          height: 4,
        ),

        Text(
          value,
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }
}