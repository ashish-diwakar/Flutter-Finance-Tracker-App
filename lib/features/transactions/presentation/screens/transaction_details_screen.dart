import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/utils/currency_formatter.dart';
import '../../../../shared/models/transaction_model.dart';
import '../../../../shared/providers/currency_provider.dart';

class TransactionDetailsScreen extends ConsumerWidget {

  final TransactionModel transaction;

  const TransactionDetailsScreen({
    super.key,
    required this.transaction,
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

    return Scaffold(

      appBar: AppBar(
        title: const Text('Transaction Details'),
      ),

      body: Padding(
        padding: const EdgeInsets.all(16),

        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,

          children: [

            Text(
              CurrencyFormatter.format(
                amount: transaction.amount,
                currency: currency,
              ),
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 16),

            Text(
              'Type: ${transaction.type}',
            ),

            const SizedBox(height: 8),

            Text(
              'Notes: ${transaction.notes ?? ''}',
            ),

            const SizedBox(height: 8),

            Text(
              'Date: ${transaction.transactionDate}',
            ),
          ],
        ),
      ),
    );
  }
}
