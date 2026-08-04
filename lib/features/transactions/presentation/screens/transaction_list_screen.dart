import 'package:finance_tracker/features/accounts/presentation/providers/accounts_provider.dart';
import 'package:finance_tracker/features/categories/presentation/providers/categories_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/models/transaction_model.dart';
import '../../../../shared/utils/transaction_date_helper.dart';
import '../providers/transaction_filter_provider.dart';
import '../../../../shared/providers/currency_provider.dart';
import '../widgets/transaction_section_header.dart';
import '../widgets/transaction_tile.dart';

class TransactionListScreen
    extends ConsumerWidget {

  final int? defaultLimit;
  const TransactionListScreen({
    super.key,
    this.defaultLimit,
  });


  @override
  Widget build(
    BuildContext context,
    WidgetRef ref,
  ) {

    final int? limit = defaultLimit;

    final transactionsAsync =
        ref.watch(
      filteredTransactionsProvider,
    );

    // final currency =
    //     ref.watch(
    //   currencyProvider,
    // );

    final accountsAsync = ref.watch(
      accountsProvider,
    );
    final categoriesAsync = ref.watch(
      allCategoriesProvider,
    );

    return transactionsAsync.when(

      data: (transactions) {

        return accountsAsync.when(

          data: (accounts) {

            return categoriesAsync.when(

              data: (categories) {

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

                final accountMap = {

                  for (final account in accounts)

                    account.uuid: account.name,
                };

                final categoryMap = {
                  for (final category in categories)
                    category.uuid: category.name,
                };

                // =====================================================
                // GROUP TRANSACTIONS
                // =====================================================

                final visibleTransactions =
                    (limit != null && limit < transactions.length)
                        ? transactions.take(limit).toList()
                        : transactions;

                final groupedTransactions =
                    <String, List<TransactionModel>>{};

                for (final transaction in visibleTransactions) {

                  final group = TransactionDateHelper.getGroupTitle(
                    transaction.transactionDate,
                  );

                  groupedTransactions.putIfAbsent(
                    group,
                    () => [],
                  );

                  groupedTransactions[group]!.add(
                    transaction,
                  );
                }

                final sectionTitles =
                    groupedTransactions.keys.toList();

                return ListView.builder(

                  padding: const EdgeInsets.only(
                    bottom: 74,
                  ),

                  itemCount: sectionTitles.length,

                  itemBuilder: (context, sectionIndex) {

                    final sectionTitle =
                        sectionTitles[sectionIndex];

                    final sectionTransactions =
                        groupedTransactions[sectionTitle]!;

                    return Column(

                      crossAxisAlignment:
                          CrossAxisAlignment.start,

                      children: [

                        // ======================================
                        // SECTION HEADER
                        // ======================================

                        TransactionSectionHeader(
                          title: sectionTitle,
                        ),

                        // ======================================
                        // TRANSACTIONS
                        // ======================================

                        ...sectionTransactions.map(

                          (transaction) {

                            // final isIncome =
                            //     transaction.type ==
                            //         'income';

                            final accountName =
                                accountMap[
                                        transaction.accountId] ??
                                    'Unknown Account';

                            final categoryName =
                                categoryMap[
                                        transaction.categoryId] ??
                                    'Unknown Category';

                            return TransactionTile(

                              transaction: transaction,

                              accountName: accountName,

                              categoryName: categoryName,
                            );
                          },
                        ),
                      ],
                    );
                  },
                );
              },
            loading: () =>

                const Center(
                  child:
                      CircularProgressIndicator(),
                ),

                error: (_, __) =>

                    const Center(
                      child: Text(
                        'Unable to load categories',
                      ),
                    ),
              );
            },

          loading: () =>

              const Center(
                child:
                    CircularProgressIndicator(),
              ),

          error: (_, __) =>

              const Center(
                child: Text(
                  'Unable to load accounts',
                ),
              ),
        );
      },

      loading: () =>

          const Center(
            child:
                CircularProgressIndicator(),
          ),

      error: (_, __) =>

          const Center(
            child: Text(
              'Unable to load transactions',
            ),
          ),
    );
  }
}
