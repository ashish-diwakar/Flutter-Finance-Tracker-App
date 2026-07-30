import 'package:finance_tracker/shared/utils/logout_app.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/services/logger_service.dart';
import '../../../../shared/utils/provider_refresh_helper.dart';
import '../../../transactions/presentation/screens/add_transaction_screen.dart';
import '../../../transactions/presentation/screens/transaction_list_screen.dart';
import '../../../auth/presentation/screens/login_screen.dart';
import '../../../sync/presentation/providers/sync_provider.dart';
import '../../../dashboard/presentation/providers/transaction_filter_provider.dart';
import '../widgets/transaction_filter_button.dart';
import '../widgets/transaction_search_bar.dart';

class TransactionListContainerScreen extends ConsumerStatefulWidget {
  const TransactionListContainerScreen({super.key});

  @override
  ConsumerState<TransactionListContainerScreen> createState() =>
      _TransactionListContainerScreenState();
}

class _TransactionListContainerScreenState
    extends ConsumerState<TransactionListContainerScreen> {
  bool syncing = false;

  Future<void> syncData() async {
    setState(() {
      syncing = true;
    });

    try {
      final syncService = await ref.read(
        syncServiceProvider.future,
      );

      await syncService.syncAll();

      await ProviderRefreshHelper.refreshTransactionData(ref);

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Sync completed'),
        ),
      );
    } catch (e, stackTrace) {
      // FIXED: Properly passing String types to your LoggerService methods
      LoggerService.error('Sync Error: $e');
      LoggerService.error('Stack Trace: $stackTrace');
        
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Unable to sync. Please try again.'),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          syncing = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        title: const Text('Transactions'),
        actions: [
          IconButton(
            tooltip: 'Sync',
            onPressed: syncing ? null : syncData,
            icon: syncing
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.sync),
          ),
          IconButton(
            tooltip: 'Logout',
            onPressed: () async {
              await LogoutAppHelper.processLogout(ref);
              if (context.mounted) {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                  (route) => false,
                );
              }
            },
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: Column(
        // children: [
        //   SizedBox(height: 16),
        //   Padding(
        //     padding: const EdgeInsets.symmetric(horizontal: 16),
        //     child: Row(
        //       mainAxisAlignment: MainAxisAlignment.spaceBetween,
        //       children: [
        //         Text(
        //           'Recent Transactions',
        //           style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        //         ),
        //         _LimitDropdown(), // FIXED: Added const anchor if applicable
        //       ],
        //     ),
        //   ),
        //   SizedBox(height: 8),
        //   Padding(
        //     padding: EdgeInsets.symmetric(horizontal: 12),
        //     child: _TypeFilterChips(),
        //   ),
        //   SizedBox(height: 8),
        //   Expanded(
        //     child: TransactionListScreen(),
        //   ),
        // ],

        children: [
          const SizedBox(
            height: 12,
          ),
          Padding(
            padding:
                const EdgeInsets.symmetric(
              horizontal: 12,
            ),
            child: Card(
              elevation: 1,
              shape:
                  RoundedRectangleBorder(
                borderRadius:
                    BorderRadius.circular(
                  16,
                ),
              ),
              child: const Padding(
                padding:
                    const EdgeInsets.all(
                  16,
                ),
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        // const Expanded(
                        //   child: Text(
                        //     'Recent Transactions',
                        //     style: TextStyle(
                        //       fontSize: 20,
                        //       fontWeight:
                        //           FontWeight.bold,
                        //     ),
                        //   ),
                        // ),
                        const Text(
                          'Show',
                        ),
                        const SizedBox(
                          width: 8,
                        ),
                        const _LimitDropdown(),
                      ],
                    ),
                    const SizedBox(
                      height: 16,
                    ),
                    const _TypeFilterChips(),
                    const SizedBox(
                      height: 16,
                    ),
                    const TransactionFilterButton(),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(
            height: 8,
          ),
          const Expanded(
            child:
                TransactionListScreen(),
          ),
        ],    
      ),
      // floatingActionButton: FloatingActionButton(
      //   heroTag: 'transactions_fab',
      //   onPressed: () {
      //     Navigator.push(
      //       context,
      //       MaterialPageRoute(builder: (_) => const AddTransactionScreen()),
      //     );
      //     ref.invalidate(
      //       filteredTransactionsProvider,
      //     );
      //   },
      //   child: const Icon(Icons.add),
      // ),
      floatingActionButton:
          FloatingActionButton(

        heroTag:
            'transactions_fab',

        child: const Icon(
          Icons.add,
        ),

        onPressed: () async {

          await Navigator.push(

            context,

            MaterialPageRoute(

              builder: (_) =>
                  const AddTransactionScreen(),
            ),
          );

          if (!mounted) {
            return;
          }

          await ProviderRefreshHelper
              .refreshTransactionData(
            ref,
          );
        },
      ),
    );
  }
}

class _LimitDropdown extends ConsumerWidget {

  const _LimitDropdown({
    super.key,
  });

  @override
  Widget build(
    BuildContext context,
    WidgetRef ref,
  ) {

    final filter =
        ref.watch(
      transactionFilterProvider,
    );

    return DropdownButtonHideUnderline(

      child: DropdownButton<TransactionLimit>(

        value: filter.limit,

        isDense: true,

        borderRadius:
            BorderRadius.circular(
          12,
        ),

        icon: const Icon(
          Icons.expand_more,
        ),

        onChanged: (value) {

          if (value == null) {
            return;
          }

          ref
              .read(
                transactionFilterProvider.notifier,
              )
              .setLimit(
                value,
              );
        },

        items: TransactionLimit.values

            .map(

              (limit) => DropdownMenuItem(

                value: limit,

                child: Text(
                  limit.label,
                ),
              ),
            )

            .toList(),
      ),
    );
  }
}

class _TypeFilterChips extends ConsumerWidget {

  const _TypeFilterChips({
    super.key,
  });

  @override
  Widget build(
    BuildContext context,
    WidgetRef ref,
  ) {

    final filter =
        ref.watch(
      transactionFilterProvider,
    );

    return SingleChildScrollView(

      scrollDirection:
          Axis.horizontal,

      child: Row(

        children:

            TransactionTypeFilter.values

                .map(

                  (type) => Padding(

                    padding:
                        const EdgeInsets.only(
                      right: 8,
                    ),

                    child: ChoiceChip(

                      label:
                          Text(
                        type.label,
                      ),

                      selected:
                          filter.type ==
                          type,

                      showCheckmark:
                          false,

                      onSelected: (_) {

                        ref
                            .read(
                              transactionFilterProvider.notifier,
                            )
                            .setType(
                              type,
                            );
                      },
                    ),
                  ),
                )

                .toList(),
      ),
    );
  }
}

class TransactionFilter {

  const TransactionFilter({

    this.limit = TransactionLimit.last10,

    this.type = TransactionTypeFilter.all,

    this.searchText = '',
  });

  final TransactionLimit limit;

  final TransactionTypeFilter type;

  final String searchText;

  TransactionFilter copyWith({

    TransactionLimit? limit,

    TransactionTypeFilter? type,

    String? searchText,
  }) {

    return TransactionFilter(

      limit: limit ?? this.limit,

      type: type ?? this.type,

      searchText:
          searchText ?? this.searchText,
    );
  }
}