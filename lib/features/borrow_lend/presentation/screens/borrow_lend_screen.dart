import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/utils/currency_formatter.dart';
import '../../../../shared/providers/currency_provider.dart';
import '../providers/borrow_lend_provider.dart';
import '../../../../core/config/currency_config.dart';
import '../../../transactions/presentation/screens/transaction_details_screen.dart';

class BorrowLendScreen
    extends ConsumerWidget {
  const BorrowLendScreen({
    super.key,
  });

  @override
  Widget build(
    BuildContext context,
    WidgetRef ref,
  ) {
    final overviewAsync =
        ref.watch(
      borrowLendOverviewProvider,
    );

    final currency =
        ref.watch(
      currencyProvider,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Borrowing & Lending',
        ),
      ),
      body: overviewAsync.when(
        loading: () =>
            const Center(
          child:
              CircularProgressIndicator(),
        ),
        error: (
          error,
          stackTrace,
        ) =>
            const Center(
          child: Text(
            'Unable to load borrowing and lending data',
          ),
        ),
        data: (overview) {
          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(
                borrowLendOverviewProvider,
              );
            },
            child: ListView(
              physics:
                  const AlwaysScrollableScrollPhysics(),
              padding:
                  const EdgeInsets.all(
                16,
              ),
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Card(
                        child: Padding(
                          padding:
                              const EdgeInsets.all(
                            16,
                          ),
                          child: Column(
                            crossAxisAlignment:
                                CrossAxisAlignment
                                    .start,
                            children: [
                              const Row(
                                children: [
                                  Icon(
                                    Icons
                                        .call_received_rounded,
                                    color:
                                        Colors.orange,
                                  ),
                                  SizedBox(
                                    width: 8,
                                  ),
                                  Expanded(
                                    child: Text(
                                      'You Owe',
                                      style:
                                          TextStyle(
                                        fontWeight:
                                            FontWeight
                                                .bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(
                                height: 12,
                              ),
                              Text(
                                CurrencyFormatter
                                    .format(
                                  amount:
                                      overview
                                          .totalOwed,
                                  currency:
                                      currency,
                                ),
                                style: Theme.of(
                                  context,
                                )
                                    .textTheme
                                    .titleLarge
                                    ?.copyWith(
                                      fontWeight:
                                          FontWeight
                                              .bold,
                                    ),
                              ),
                              const SizedBox(
                                height: 4,
                              ),
                              Text(
                                '${overview.borrowed.length} '
                                '${overview.borrowed.length == 1 ? 'record' : 'records'}',
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(
                      width: 12,
                    ),
                    Expanded(
                      child: Card(
                        child: Padding(
                          padding:
                              const EdgeInsets.all(
                            16,
                          ),
                          child: Column(
                            crossAxisAlignment:
                                CrossAxisAlignment
                                    .start,
                            children: [
                              const Row(
                                children: [
                                  Icon(
                                    Icons
                                        .call_made_rounded,
                                    color:
                                        Colors.green,
                                  ),
                                  SizedBox(
                                    width: 8,
                                  ),
                                  Expanded(
                                    child: Text(
                                      'Owed to You',
                                      style:
                                          TextStyle(
                                        fontWeight:
                                            FontWeight
                                                .bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(
                                height: 12,
                              ),
                              Text(
                                CurrencyFormatter
                                    .format(
                                  amount:
                                      overview
                                          .totalReceivable,
                                  currency:
                                      currency,
                                ),
                                style: Theme.of(
                                  context,
                                )
                                    .textTheme
                                    .titleLarge
                                    ?.copyWith(
                                      fontWeight:
                                          FontWeight
                                              .bold,
                                    ),
                              ),
                              const SizedBox(
                                height: 4,
                              ),
                              Text(
                                '${overview.lent.length} '
                                '${overview.lent.length == 1 ? 'record' : 'records'}',
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 24,
                ),
                _buildSection(
                  context: context,
                  title: 'Money You Owe',
                  items: _sortedItems(
                    overview.borrowed,
                  ),
                  currency: currency,
                ),

                const SizedBox(
                  height: 24,
                ),

                _buildSection(
                  context: context,
                  title: 'Money Owed to You',
                  items: _sortedItems(
                    overview.lent,
                  ),
                  currency: currency,
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  List<BorrowLendItem> _sortedItems(
    List<BorrowLendItem> items,
  ) {
    final now =
        DateTime.now();

    final sorted =
        List<BorrowLendItem>.from(
      items,
    );

    sorted.sort(
      (a, b) {
        final aStatus =
            a.status(
          now: now,
        );

        final bStatus =
            b.status(
          now: now,
        );

        final statusComparison =
            _statusPriority(aStatus)
                .compareTo(
          _statusPriority(bStatus),
        );

        if (statusComparison != 0) {
          return statusComparison;
        }

        final aDueDate =
            a.transaction.dueDate
                ?.toLocal();

        final bDueDate =
            b.transaction.dueDate
                ?.toLocal();

        if (aDueDate != null &&
            bDueDate != null) {
          return aDueDate.compareTo(
            bDueDate,
          );
        }

        if (aDueDate != null) {
          return -1;
        }

        if (bDueDate != null) {
          return 1;
        }

        return b.transaction
            .transactionDate
            .compareTo(
          a.transaction.transactionDate,
        );
      },
    );

    return sorted;
  }

  int _statusPriority(
    BorrowLendStatus status,
  ) {
    switch (status) {
      case BorrowLendStatus.overdue:
        return 0;

      case BorrowLendStatus.dueSoon:
        return 1;

      case BorrowLendStatus.active:
        return 2;

      case BorrowLendStatus.settled:
        return 3;
    }
  }

  Widget _buildSection({
    required BuildContext context,
    required String title,
    required List<BorrowLendItem> items,
    required CurrencyConfig currency,
  }) {
    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context)
              .textTheme
              .titleMedium
              ?.copyWith(
                fontWeight:
                    FontWeight.bold,
              ),
        ),

        const SizedBox(
          height: 10,
        ),

        if (items.isEmpty)
          Card(
            child: Padding(
              padding:
                  const EdgeInsets.all(
                20,
              ),
              child: Center(
                child: Text(
                  title ==
                          'Money You Owe'
                      ? 'No borrowed money'
                      : 'No money owed to you',
                ),
              ),
            ),
          )
        else
          ...items.map(
            (item) =>
                _buildBorrowLendItem(
              context: context,
              item: item,
              currency: currency,
            ),
          ),
      ],
    );
  }

  Widget _buildBorrowLendItem({
    required BuildContext context,
    required BorrowLendItem item,
    required CurrencyConfig currency,
  }) {
    final transaction =
        item.transaction;

    final counterparty =
        transaction
            .counterpartyName
            ?.trim();

    final displayName =
        counterparty == null ||
                counterparty.isEmpty
            ? 'Unknown Counterparty'
            : counterparty;

    final isBorrowed =
        transaction.type ==
            'borrowed';

    final status =
        item.status();

    return Card(
      margin:
          const EdgeInsets.only(
        bottom: 10,
      ),
      child: InkWell(
        borderRadius:
            BorderRadius.circular(
          12,
        ),
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
        child: Padding(
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
                  CircleAvatar(
                    child: Icon(
                      isBorrowed
                          ? Icons
                              .call_received_rounded
                          : Icons
                              .call_made_rounded,
                    ),
                  ),

                  const SizedBox(
                    width: 12,
                  ),

                  Expanded(
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment
                              .start,
                      children: [
                        Text(
                          displayName,
                          style: Theme.of(
                            context,
                          )
                              .textTheme
                              .titleMedium
                              ?.copyWith(
                                fontWeight:
                                    FontWeight
                                        .bold,
                              ),
                        ),

                        Text(
                          isBorrowed
                              ? 'Borrowed'
                              : 'Lent',
                        ),
                      ],
                    ),
                  ),

                  Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.end,
                    children: [
                      Container(
                        padding:
                            const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: _statusColor(
                            status,
                          ).withValues(
                            alpha: 0.12,
                          ),
                          borderRadius:
                              BorderRadius.circular(
                            12,
                          ),
                        ),
                        child: Text(
                          _statusLabel(
                            status,
                          ),
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight:
                                FontWeight.w600,
                            color: _statusColor(
                              status,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(
                        height: 6,
                      ),

                      const Icon(
                        Icons.chevron_right,
                        size: 20,
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(
                height: 16,
              ),

              Row(
                children: [
                  Expanded(
                    child: _amountDetail(
                      context:
                          context,
                      label:
                          'Original',
                      amount:
                          transaction
                              .amount,
                      currency:
                          currency,
                    ),
                  ),

                  Expanded(
                    child: _amountDetail(
                      context:
                          context,
                      label: isBorrowed
                          ? 'Repaid'
                          : 'Received',
                      amount:
                          item.repaidAmount,
                      currency:
                          currency,
                    ),
                  ),
                ],
              ),

              const SizedBox(
                height: 12,
              ),

              Text(
                isBorrowed
                    ? 'Outstanding'
                    : 'Receivable',
                style: Theme.of(
                  context,
                )
                    .textTheme
                    .bodySmall,
              ),

              const SizedBox(
                height: 2,
              ),

              Text(
                CurrencyFormatter
                    .format(
                  amount:
                      item.outstandingAmount,
                  currency:
                      currency,
                ),
                style: Theme.of(
                  context,
                )
                    .textTheme
                    .titleLarge
                    ?.copyWith(
                      fontWeight:
                          FontWeight.bold,
                    ),
              ),

              if (transaction
                      .dueDate !=
                  null) ...[
                const SizedBox(
                  height: 10,
                ),
                Text(
                  'Due: ${_formatDate(
                    transaction.dueDate!,
                  )}',
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _amountDetail({
    required BuildContext context,
    required String label,
    required int amount,
    required CurrencyConfig currency,
  }) {
    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(
            context,
          ).textTheme.bodySmall,
        ),
        const SizedBox(
          height: 2,
        ),
        Text(
          CurrencyFormatter.format(
            amount: amount,
            currency: currency,
          ),
          style: const TextStyle(
            fontWeight:
                FontWeight.w600,
          ),
        ),
      ],
    );
  }

  String _formatDate(
    DateTime date,
  ) {
    final local =
        date.toLocal();

    return '${local.day.toString().padLeft(2, '0')}/'
        '${local.month.toString().padLeft(2, '0')}/'
        '${local.year}';
  }

  String _statusLabel(
    BorrowLendStatus status,
  ) {
    switch (status) {
      case BorrowLendStatus.active:
        return 'Active';

      case BorrowLendStatus.dueSoon:
        return 'Due Soon';

      case BorrowLendStatus.overdue:
        return 'Overdue';

      case BorrowLendStatus.settled:
        return 'Settled';
    }
  }

  Color _statusColor(
    BorrowLendStatus status,
  ) {
    switch (status) {
      case BorrowLendStatus.active:
        return Colors.blue;

      case BorrowLendStatus.dueSoon:
        return Colors.orange;

      case BorrowLendStatus.overdue:
        return Colors.red;

      case BorrowLendStatus.settled:
        return Colors.green;
    }
  }

}