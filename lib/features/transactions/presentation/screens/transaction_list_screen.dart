import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/transaction_repository.dart';
import '../providers/transaction_repository_provider.dart';

class TransactionListScreen extends ConsumerWidget {
  const TransactionListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {

    final repositoryAsync =
        ref.watch(transactionRepositoryProvider);

    return repositoryAsync.when(
      data: (TransactionRepository repository) {
        return FutureBuilder(
          future: repository.getTransactions(),
          builder: (context, snapshot) {

            if (!snapshot.hasData) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            final transactions = snapshot.data!;

            if (transactions.isEmpty) {
              return const Center(
                child: Text('No Transactions'),
              );
            }

            return ListView.builder(
              itemCount: transactions.length,
              itemBuilder: (context, index) {

                final transaction = transactions[index];

                return ListTile(
                  leading: Icon(
                    transaction.type == 'income'
                        ? Icons.arrow_downward
                        : Icons.arrow_upward,
                  ),
                  title: Text(
                    '₹ ${(transaction.amount / 100).toStringAsFixed(2)}',
                  ),
                  subtitle: Text(
                    transaction.notes ?? '',
                  ),
                );
              },
            );
          },
        );
      },
      error: (e, s) => Center(
        child: Text(e.toString()),
      ),
      loading: () => const Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}