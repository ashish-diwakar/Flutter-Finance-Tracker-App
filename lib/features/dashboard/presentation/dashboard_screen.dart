import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/models/transaction_model.dart';
import '../../transactions/presentation/providers/transaction_repository_provider.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Finance Tracker'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () async {
            final repository =
                await ref.read(transactionRepositoryProvider.future);

            final transaction = TransactionModel()
              ..amount = 50000
              ..type = 'income'
              ..transactionDate = DateTime.now()
              ..categoryId = 1
              ..accountId = 1
              ..notes = 'Test Income';

            await repository.addTransaction(transaction);

            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Transaction Added'),
              ),
            );
          },
          child: const Text('Insert Transaction'),
        ),
      ),
    );
  }
}