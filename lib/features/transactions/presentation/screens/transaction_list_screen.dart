import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/utils/currency_formatter.dart';
import '../../../../shared/utils/provider_refresh_helper.dart' show ProviderRefreshHelper;
import '../../../dashboard/presentation/providers/balance_provider.dart';
import '../../../dashboard/presentation/providers/expense_provider.dart';
import '../../../dashboard/presentation/providers/income_provider.dart';
import '../../../dashboard/presentation/providers/transaction_filter_provider.dart';
import '../../../dashboard/presentation/providers/transactions_provider.dart';
import '../providers/transaction_repository_provider.dart';
import '../../../../shared/providers/currency_provider.dart';
import 'add_transaction_screen.dart';
import 'transaction_details_screen.dart';

class TransactionListScreen
    extends ConsumerWidget {

  final int? defaultLimit;
  const TransactionListScreen({
    super.key,
    this.defaultLimit,
  });

  Future<void> deleteTransaction({
    required BuildContext context,
    required WidgetRef ref,
    required dynamic transaction,
  }) async {

    final confirm =
        await showDialog<bool>(
      context: context,

      builder: (_) {

        return AlertDialog(

          title: const Text(
            'Delete Transaction',
          ),

          content: const Text(
            'Are you sure you want to delete this transaction?',
          ),

          actions: [

            TextButton(

              onPressed: () {

                Navigator.pop(
                  context,
                  false,
                );
              },

              child: const Text(
                'Cancel',
              ),
            ),

            ElevatedButton(

              onPressed: () {

                Navigator.pop(
                  context,
                  true,
                );
              },

              child: const Text(
                'Delete',
              ),
            ),
          ],
        );
      },
    );

    if (confirm != true) {
      return;
    }

    try {

      final repository =
          await ref.read(
        transactionRepositoryProvider
            .future,
      );

      await repository
          .deleteTransaction(
        transaction,
      );

      await ProviderRefreshHelper
          .refreshAllFinancialData(
        ref,
      );

      if (context.mounted) {

        ScaffoldMessenger.of(
          context,
        ).showSnackBar(

          const SnackBar(
            content: Text(
              'Transaction deleted',
            ),
          ),
        );
      }

    } catch (_) {

      if (context.mounted) {

        ScaffoldMessenger.of(
          context,
        ).showSnackBar(

          const SnackBar(
            content: Text(
              'Unable to delete transaction',
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(
    BuildContext context,
    WidgetRef ref,
  ) {

    final limit = (defaultLimit != null)
        ? defaultLimit
        : 5;

    final transactionsAsync =
        ref.watch(
      filteredTransactionsProvider,
    );

    final currency =
        ref.watch(
      currencyProvider,
    );

    return transactionsAsync.when(

      data: (transactions) {

        if (transactions.isEmpty) {

          return const Center(

            child: Column(

              mainAxisAlignment:
                  MainAxisAlignment.center,

              children: [

                Icon(
                  Icons.receipt_long,
                  size: 64,
                  color: Colors.grey,
                ),

                SizedBox(height: 12),

                Text(
                  'No Transactions',
                  style: TextStyle(
                    fontSize: 18,
                  ),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          
          shrinkWrap: true,

          physics:
              const NeverScrollableScrollPhysics(),
              
          itemCount:
              (limit != null && limit < transactions.length)
                  ? limit
                  : transactions.length,

          itemBuilder:
              (context, index) {

            final transaction =
                transactions[index];

            final isIncome =
                transaction.type ==
                    'income';

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

                  child: isIncome
                    ? const Icon(
                        Icons.attach_money,
                        color: Colors.green,
                      )
                    : const Icon(
                        Icons.money_off,
                        color: Colors.red,
                      ),

                  // child: Icon(
                  //   isIncome
                  //       ? Icons.money
                  //       : Icons.money_off,
                  // ),
                ),

                title: Text(
                  CurrencyFormatter.format(
                    amount: transaction.amount,
                    currency: currency,
                  ),
                ),

                subtitle: Column(

                  crossAxisAlignment:
                      CrossAxisAlignment.start,

                  children: [

                    if ((transaction.notes ??
                            '')
                        .trim()
                        .isNotEmpty)

                      Text(
                        transaction.notes!,
                      ),

                    const SizedBox(
                      height: 4,
                    ),

                    Text(
                      DateFormat(
                        'dd MMM yyyy',
                      ).format(
                        transaction.transactionDate,
                      ),

                      style: const TextStyle(
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),

                trailing: Row(

                  mainAxisSize:
                      MainAxisSize.min,

                  children: [

                    Icon(
                      transaction.isSynced
                          ? Icons.cloud_done
                          : Icons.cloud_off,

                      size: 18,
                    ),


                    PopupMenuButton<String>(

                      padding: EdgeInsets.zero,

                      constraints:
                          const BoxConstraints(),

                      onSelected:
                          (value) async {

                        if (value == 'edit') {

                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  AddTransactionScreen(
                                transaction:
                                    transaction,
                              ),
                            ),
                          );
                        }

                        if (value == 'delete') {

                          await deleteTransaction(
                            context: context,
                            ref: ref,
                            transaction: transaction,
                          );
                        }
                      },

                      itemBuilder: (_) => [

                        const PopupMenuItem(

                          value: 'edit',

                          child: Text(
                            'Edit',
                          ),
                        ),

                        const PopupMenuItem(

                          value: 'delete',

                          child: Text(
                            'Delete',
                          ),
                        ),
                      ],
                    ),

                    // const SizedBox(
                    //   height: 2,
                    // ),

                    // Icon(

                    //   transaction.isSynced
                    //       ? Icons.cloud_done
                    //       : Icons.cloud_off,

                    //   size: 14,
                    // ),
                  ],
                ),
              ),
            );
          },
        );
      },

      error: (_, __) =>

          const Center(
            child: Text(
              'Unable to load transactions',
            ),
          ),

      loading: () =>

          const Center(
            child:
                CircularProgressIndicator(),
          ),
    );
  }
}
