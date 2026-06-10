import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/utils/currency_formatter.dart';
import '../../../../shared/utils/provider_refresh_helper.dart';
import '../providers/recurring_provider.dart';
import 'add_recurring_transaction_screen.dart';
import '../../../../shared/providers/currency_provider.dart';

class RecurringTransactionsScreen
    extends ConsumerWidget {

  const RecurringTransactionsScreen({
    super.key,
  });

  @override
  Widget build(
    BuildContext context,
    WidgetRef ref,
  ) {

    final recurringAsync =
        ref.watch(
      recurringTransactionsProvider,
    );

    final currency =
        ref.watch(
      currencyProvider,
    );

    return Scaffold(

      appBar: AppBar(

        title: const Text(
          'Recurring Transactions',
        ),
      ),

      floatingActionButton:
          FloatingActionButton(

        heroTag:
            'recurring_fab',

        onPressed: () async {

          await Navigator.push(

            context,

            MaterialPageRoute(

              builder: (_) =>
                  const AddRecurringTransactionScreen(),
            ),
          );

          await ProviderRefreshHelper
            .refreshRecurringTransactionData(ref);
        },

        child: const Icon(
          Icons.add,
        ),
      ),

      body: recurringAsync.when(

        data: (items) {

          if (items.isEmpty) {

            return const Center(

              child: Text(
                'No recurring transactions',
              ),
            );
          }

          return ListView.builder(

            padding:
                const EdgeInsets.only(
              bottom: 100,
            ),

            itemCount:
                items.length,

            itemBuilder:
                (context, index) {

              final item =
                  items[index];

              return Card(

                margin:
                    const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),

                child: ListTile(

                  leading: CircleAvatar(

                    child: Icon(

                      item.type ==
                              'income'

                          ? Icons
                              .arrow_downward

                          : Icons
                              .arrow_upward,
                    ),
                  ),

                  title: Column(

                    crossAxisAlignment:
                        CrossAxisAlignment.start,

                    children: [

                      Text(

                        item.notes?.trim().isNotEmpty ==
                                true

                            ? item.notes!

                            : 'Recurring Transaction',
                      ),

                      const SizedBox(
                        height: 4,
                      ),

                      Text(

                        CurrencyFormatter.format(
                          amount: item.amount,
                          currency: currency,
                        ),

                        style: const TextStyle(

                          fontWeight:
                              FontWeight.bold,
                        ),
                      ),
                    ],
                  ),

                  subtitle: Column(

                    crossAxisAlignment:
                        CrossAxisAlignment.start,

                    children: [

                      Text(

                        '${item.frequency.toUpperCase()} • Every ${item.interval}',
                      ),

                      const SizedBox(
                        height: 4,
                      ),

                      Text(

                        'Next: ${item.nextRunDate.day}/${item.nextRunDate.month}/${item.nextRunDate.year}',
                      ),

                      const SizedBox(
                        height: 4,
                      ),

                      Text(

                        item.isActive

                            ? 'Active'

                            : 'Paused',

                        style: TextStyle(

                          color:

                              item.isActive

                                  ? Colors.green

                                  : Colors.orange,

                          fontWeight:
                              FontWeight.w600,
                        ),
                      ),
                    ],
                  ),

                  trailing: PopupMenuButton<String>(

                      onSelected: (value) async {

                        // =====================================
                        // TOGGLE ACTIVE
                        // =====================================

                        if (value == 'toggle') {

                          final repository =
                              await ref.read(
                            recurringRepositoryProvider
                                .future,
                          );

                          item.isActive =
                              !item.isActive;

                          item.updatedAt =
                              DateTime.now();

                          item.isSynced =
                              false;

                          await repository
                              .updateRecurring(
                            item,
                          );

                          await ProviderRefreshHelper
                            .refreshRecurringTransactionData(ref);
                        }

                        // =====================================
                        // EDIT
                        // =====================================

                        if (value == 'edit') {

                          await Navigator.push(

                            context,

                            MaterialPageRoute(

                              builder: (_) =>
                                  AddRecurringTransactionScreen(
                                recurring: item,
                              ),
                            ),
                          );

                          await ProviderRefreshHelper
                            .refreshRecurringTransactionData(ref);
                        }

                        // =====================================
                        // DELETE
                        // =====================================

                        if (value == 'delete') {

                          final confirm =
                              await showDialog<bool>(

                            context: context,

                            builder: (_) {

                              return AlertDialog(

                                title: const Text(
                                  'Delete Recurring Transaction',
                                ),

                                content: const Text(
                                  'Are you sure you want to delete this recurring transaction?',
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

                          final repository =
                              await ref.read(
                            recurringRepositoryProvider
                                .future,
                          );

                          await repository
                              .deleteRecurring(
                            item,
                          );

                          await ProviderRefreshHelper
                            .refreshRecurringTransactionData(ref);

                          if (context.mounted) {

                            ScaffoldMessenger.of(
                              context,
                            ).showSnackBar(

                              const SnackBar(

                                content: Text(
                                  'Recurring transaction deleted',
                                ),
                              ),
                            );
                          }
                        }
                      },

                      itemBuilder: (_) => [

                        PopupMenuItem(

                          value: 'toggle',

                          child: Row(

                            children: [

                              Icon(

                                item.isActive

                                    ? Icons.pause

                                    : Icons.play_arrow,
                              ),

                              const SizedBox(
                                width: 12,
                              ),

                              Text(

                                item.isActive

                                    ? 'Pause'

                                    : 'Activate',
                              ),
                            ],
                          ),
                        ),

                        const PopupMenuItem(

                          value: 'edit',

                          child: Row(

                            children: [

                              Icon(Icons.edit),

                              SizedBox(width: 12),

                              Text('Edit'),
                            ],
                          ),
                        ),

                        const PopupMenuItem(

                          value: 'delete',

                          child: Row(

                            children: [

                              Icon(Icons.delete),

                              SizedBox(width: 12),

                              Text('Delete'),
                            ],
                          ),
                        ),
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
                'Unable to load recurring transactions',
              ),
            ),

        loading: () =>

            const Center(
              child:
                  CircularProgressIndicator(),
            ),
      ),
    );
  }
}
