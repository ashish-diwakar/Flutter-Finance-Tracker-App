import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/utils/currency_formatter.dart';
import '../../../../shared/models/transaction_model.dart';
import '../../../../shared/providers/currency_provider.dart';
import 'package:finance_tracker/features/accounts/presentation/providers/accounts_provider.dart';
import 'package:finance_tracker/features/categories/presentation/providers/categories_provider.dart';


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
    final theme = Theme.of(context);

    final currency =
        ref.watch(currencyProvider);

    final isIncome =
        transaction.type.toLowerCase() == 'income';

    final amountColor = isIncome
        ? Colors.green
        : Colors.red;

    final amountPrefix =
        isIncome ? '+' : '-';

    // =====================================================
    // CATEGORY
    // =====================================================

    final categoriesAsync =
        ref.watch(
      allCategoriesProvider,
    );

    final categoryName =
        categoriesAsync.when(
      data: (categories) {
        final matching =
            categories.where(
          (category) =>
              category.uuid ==
              transaction.categoryId,
        );

        if (matching.isEmpty) {
          return 'Unknown Category';
        }

        return matching.first.name;
      },
      loading: () => 'Loading...',
      error: (_, __) => 'Unknown Category',
    );

    // =====================================================
    // ACCOUNT
    // =====================================================

    final accountsAsync =
        ref.watch(accountsProvider);

    final accountName =
        accountsAsync.when(
      data: (accounts) {
        final matching =
            accounts.where(
          (account) =>
              account.uuid ==
              transaction.accountId,
        );

        if (matching.isEmpty) {
          return 'Unknown Account';
        }

        return matching.first.name;
      },
      loading: () => 'Loading...',
      error: (_, __) => 'Unknown Account',
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Transaction Details',
        ),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),

        child: Column(
          children: [

            // =====================================================
            // AMOUNT CARD
            // =====================================================

            Card(
              elevation: 1,

              child: Padding(
                padding:
                    const EdgeInsets.all(24),

                child: Column(
                  children: [

                    Container(
                      width: 64,
                      height: 64,

                      decoration: BoxDecoration(
                        color: amountColor
                            .withValues(
                          alpha: 0.12,
                        ),

                        shape:
                            BoxShape.circle,
                      ),

                      child: Icon(
                        isIncome
                            ? Icons
                                .arrow_downward_rounded
                            : Icons
                                .arrow_upward_rounded,

                        size: 32,

                        color:
                            amountColor,
                      ),
                    ),

                    const SizedBox(
                      height: 16,
                    ),

                    Text(
                      '$amountPrefix${CurrencyFormatter.format(
                        amount:
                            transaction.amount,
                        currency:
                            currency,
                      )}',

                      textAlign:
                          TextAlign.center,

                      style: theme
                          .textTheme
                          .headlineMedium
                          ?.copyWith(
                        fontWeight:
                            FontWeight.bold,

                        color:
                            amountColor,
                      ),
                    ),

                    const SizedBox(
                      height: 8,
                    ),

                    Container(
                      padding:
                          const EdgeInsets
                              .symmetric(
                        horizontal: 14,
                        vertical: 6,
                      ),

                      decoration:
                          BoxDecoration(
                        color: amountColor
                            .withValues(
                          alpha: 0.10,
                        ),

                        borderRadius:
                            BorderRadius
                                .circular(
                          20,
                        ),
                      ),

                      child: Text(
                        isIncome
                            ? 'Income'
                            : 'Expense',

                        style: TextStyle(
                          color:
                              amountColor,

                          fontWeight:
                              FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(
              height: 16,
            ),

            // =====================================================
            // TRANSACTION INFORMATION
            // =====================================================

            Card(
              child: Padding(
                padding:
                    const EdgeInsets.all(20),

                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,

                  children: [

                    Text(
                      'Transaction Information',

                      style: theme
                          .textTheme
                          .titleLarge
                          ?.copyWith(
                        fontWeight:
                            FontWeight.bold,
                      ),
                    ),

                    const SizedBox(
                      height: 16,
                    ),

                    _DetailRow(
                      icon:
                          Icons.category_outlined,

                      label:
                          'Category',

                      value:
                          categoryName,
                    ),

                    const Divider(
                      height: 24,
                    ),

                    _DetailRow(
                      icon:
                          Icons.account_balance_wallet_outlined,

                      label:
                          'Account',

                      value:
                          accountName,
                    ),

                    const Divider(
                      height: 24,
                    ),

                    _DetailRow(
                      icon:
                          Icons.calendar_today_outlined,

                      label:
                          'Date',

                      value:
                          _formatDate(
                        transaction
                            .transactionDate,
                      ),
                    ),

                    const Divider(
                      height: 24,
                    ),

                    _DetailRow(
                      icon:
                          Icons.access_time_outlined,

                      label:
                          'Time',

                      value:
                          _formatTime(
                        transaction
                            .transactionDate,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(
              height: 16,
            ),

            // =====================================================
            // NOTES
            // =====================================================

            if (transaction.notes != null &&
                transaction.notes!
                    .trim()
                    .isNotEmpty)
              Card(
                child: Padding(
                  padding:
                      const EdgeInsets.all(20),

                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,

                    children: [

                      Text(
                        'Notes',

                        style: theme
                            .textTheme
                            .titleLarge
                            ?.copyWith(
                          fontWeight:
                              FontWeight.bold,
                        ),
                      ),

                      const SizedBox(
                        height: 12,
                      ),

                      Container(
                        width:
                            double.infinity,

                        padding:
                            const EdgeInsets.all(
                          16,
                        ),

                        decoration:
                            BoxDecoration(
                          color: theme
                              .colorScheme
                              .surfaceContainerHighest,

                          borderRadius:
                              BorderRadius
                                  .circular(
                            12,
                          ),
                        ),

                        child: Text(
                          transaction
                              .notes!
                              .trim(),

                          style: theme
                              .textTheme
                              .bodyLarge,

                          softWrap:
                              true,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            const SizedBox(
              height: 16,
            ),

            // =====================================================
            // RECORD INFORMATION
            // =====================================================

            Card(
              child: Padding(
                padding:
                    const EdgeInsets.all(20),

                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,

                  children: [

                    Text(
                      'Record Information',

                      style: theme
                          .textTheme
                          .titleLarge
                          ?.copyWith(
                        fontWeight:
                            FontWeight.bold,
                      ),
                    ),

                    const SizedBox(
                      height: 16,
                    ),

                    _DetailRow(
                      icon:
                          Icons.update_outlined,

                      label:
                          'Last Updated',

                      value:
                          _formatDateTime(
                        transaction
                            .updatedAt,
                      ),
                    ),

                    const Divider(
                      height: 24,
                    ),

                    _DetailRow(
                      icon:
                          Icons.cloud_done_outlined,

                      label:
                          'Sync Status',

                      value:
                          transaction
                                  .isSynced
                              ? 'Synced'
                              : 'Local',
                    ),

                    if (transaction
                        .isDeleted) ...[
                      const Divider(
                        height: 24,
                      ),

                      _DetailRow(
                        icon:
                            Icons.delete_outline,

                        label:
                            'Status',

                        value:
                            'Deleted',
                      ),
                    ],
                  ],
                ),
              ),
            ),

            const SizedBox(
              height: 16,
            ),

            // =====================================================
            // TRANSACTION ID
            // =====================================================

            Card(
              child: Padding(
                padding:
                    const EdgeInsets.all(20),

                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,

                  children: [

                    Text(
                      'Transaction ID',

                      style: theme
                          .textTheme
                          .titleMedium
                          ?.copyWith(
                        fontWeight:
                            FontWeight.bold,
                      ),
                    ),

                    const SizedBox(
                      height: 8,
                    ),

                    SelectableText(
                      transaction.uuid,
                      style: theme
                          .textTheme
                          .bodySmall
                          ?.copyWith(
                        color: theme
                            .colorScheme
                            .onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(
              height: 48,
            ),
          ],
        ),
      ),
    );
  }

  // =====================================================
  // DATE
  // =====================================================

  static String _formatDate(
    DateTime date,
  ) {
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
  }

  // =====================================================
  // TIME
  // =====================================================

  static String _formatTime(
    DateTime date,
  ) {
    final hour =
        date.hour == 0
            ? 12
            : date.hour > 12
                ? date.hour - 12
                : date.hour;

    final minute =
        date.minute
            .toString()
            .padLeft(
              2,
              '0',
            );

    final period =
        date.hour >= 12
            ? 'PM'
            : 'AM';

    return '$hour:$minute $period';
  }

  // =====================================================
  // DATE + TIME
  // =====================================================

  static String _formatDateTime(
    DateTime? date,
  ) {
    if (date == null) {
      return 'N/A';
    }

    return '${_formatDate(date)} '
        '${_formatTime(date)}';
  }
}

// =====================================================
// DETAIL ROW
// =====================================================

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    final theme =
        Theme.of(context);

    return Row(
      crossAxisAlignment:
          CrossAxisAlignment.start,

      children: [

        Container(
          width: 42,
          height: 42,

          decoration:
              BoxDecoration(
            color: theme
                .colorScheme
                .primary
                .withValues(
              alpha: 0.10,
            ),

            borderRadius:
                BorderRadius.circular(
              12,
            ),
          ),

          child: Icon(
            icon,
            size: 22,
            color: theme
                .colorScheme
                .primary,
          ),
        ),

        const SizedBox(
          width: 14,
        ),

        Expanded(
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,

            children: [

              Text(
                label,

                style: theme
                    .textTheme
                    .bodySmall
                    ?.copyWith(
                  color: theme
                      .colorScheme
                      .onSurfaceVariant,
                ),
              ),

              const SizedBox(
                height: 3,
              ),

              Text(
                value,

                style: theme
                    .textTheme
                    .bodyLarge
                    ?.copyWith(
                  fontWeight:
                      FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}