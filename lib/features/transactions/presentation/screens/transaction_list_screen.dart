import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/utils/currency_formatter.dart';
import '../../../dashboard/presentation/providers/transactions_provider.dart';
import 'transaction_details_screen.dart';

class TransactionListScreen
    extends ConsumerWidget {

  const TransactionListScreen({
    super.key,
  });

  @override
  Widget build(
    BuildContext context,
    WidgetRef ref,
  ) {

    final transactionsAsync =
        ref.watch(
          transactionsStreamProvider,
        );

    return transactionsAsync.when(

      data: (transactions) {

        if (transactions.isEmpty) {

          return const Center(
            child: Text('No Transactions'),
          );
        }

        return ListView.builder(

          itemCount: transactions.length,

          itemBuilder: (context, index) {

            final transaction =
                transactions[index];

            return Card(

              margin:
                  const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 4,
              ),

              child: ListTile(

                onTap: () {

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          TransactionDetailsScreen(
                        transaction:
                            transaction,
                      ),
                    ),
                  );
                },

                leading: CircleAvatar(

                  child: Icon(
                    transaction.type ==
                            'income'
                        ? Icons.arrow_downward
                        : Icons.arrow_upward,
                  ),
                ),

                title: Text(
                  CurrencyFormatter.format(
                    transaction.amount,
                  ),
                ),

                subtitle: Text(
                  transaction.notes ?? '',
                ),

                trailing: Column(
                  mainAxisAlignment:
                      MainAxisAlignment.center,

                  children: [

                    Text(
                      transaction.type
                          .toUpperCase(),
                    ),

                    Icon(
                      transaction.isSynced
                          ? Icons.cloud_done
                          : Icons.cloud_off,

                      size: 16,
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },

      error: (e, s) =>
          Center(
            child: Text(e.toString()),
          ),

      loading: () =>
          const Center(
            child:
                CircularProgressIndicator(),
          ),
    );
  }
}