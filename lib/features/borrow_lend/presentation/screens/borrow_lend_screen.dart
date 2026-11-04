import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/widgets/aurora_app_bar.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../shared/providers/currency_provider.dart';
import '../providers/borrow_lend_provider.dart';
import '../../../../core/config/currency_config.dart';
import '../../../transactions/presentation/screens/transaction_details_screen.dart';

class _BorrowLendSummaryCard extends StatelessWidget {
  final String title;
  final String amount;
  final String recordCount;
  final IconData icon;
  final Color backgroundColor;
  final Color borderColor;
  final Color accentColor;

  const _BorrowLendSummaryCard({
    required this.title,
    required this.amount,
    required this.recordCount,
    required this.icon,
    required this.backgroundColor,
    required this.borderColor,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      color: backgroundColor,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: borderColor),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(icon, color: accentColor, size: 21),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      color: accentColor,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              amount,
              style: TextStyle(
                color: accentColor,
                fontSize: 22,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              recordCount,
              style: TextStyle(
                color: accentColor,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class BorrowLendScreen extends ConsumerWidget {
  const BorrowLendScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final overviewAsync = ref.watch(borrowLendOverviewProvider);

    final currency = ref.watch(currencyProvider);

    return Scaffold(
      appBar: const AuroraAppBar(title: Text('Borrowing & Lending')),
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: [Color(0xFFB6D7CC), Color(0xFFDAEDE5), Color(0xFFF8FCFA)],
            stops: [0.0, 0.52, 1.0],
          ),
        ),
        child: overviewAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stackTrace) => const Center(
            child: Text('Unable to load borrowing and lending data'),
          ),
          data: (overview) {
            return RefreshIndicator(
              onRefresh: () async {
                ref.invalidate(borrowLendOverviewProvider);
              },
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                children: [
                  IntrinsicHeight(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Expanded(
                          child: _BorrowLendSummaryCard(
                            title: 'You Owe',
                            amount: CurrencyFormatter.format(
                              amount: overview.totalOwed,
                              currency: currency,
                            ),
                            recordCount:
                                '${overview.borrowed.length} '
                                '${overview.borrowed.length == 1 ? 'record' : 'records'}',
                            icon: Icons.call_received_rounded,
                            backgroundColor: const Color(0xFFFFF5E8),
                            borderColor: const Color(0xFFF0D6B8),
                            accentColor: const Color(0xFF80552C),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _BorrowLendSummaryCard(
                            title: 'Owed to You',
                            amount: CurrencyFormatter.format(
                              amount: overview.totalReceivable,
                              currency: currency,
                            ),
                            recordCount:
                                '${overview.lent.length} '
                                '${overview.lent.length == 1 ? 'record' : 'records'}',
                            icon: Icons.call_made_rounded,
                            backgroundColor: const Color(0xFFE9F8EE),
                            borderColor: const Color(0xFFB9DEC5),
                            accentColor: const Color(0xFF256141),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  _buildSection(
                    context: context,
                    title: 'Money You Owe',
                    items: _sortedItems(overview.borrowed),
                    currency: currency,
                  ),

                  const SizedBox(height: 24),

                  _buildSection(
                    context: context,
                    title: 'Money Owed to You',
                    items: _sortedItems(overview.lent),
                    currency: currency,
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  List<BorrowLendItem> _sortedItems(List<BorrowLendItem> items) {
    final now = DateTime.now();

    final sorted = List<BorrowLendItem>.from(items);

    sorted.sort((a, b) {
      final aStatus = a.status(now: now);

      final bStatus = b.status(now: now);

      final statusComparison = _statusPriority(
        aStatus,
      ).compareTo(_statusPriority(bStatus));

      if (statusComparison != 0) {
        return statusComparison;
      }

      final aDueDate = a.transaction.dueDate?.toLocal();

      final bDueDate = b.transaction.dueDate?.toLocal();

      if (aDueDate != null && bDueDate != null) {
        return aDueDate.compareTo(bDueDate);
      }

      if (aDueDate != null) {
        return -1;
      }

      if (bDueDate != null) {
        return 1;
      }

      return b.transaction.transactionDate.compareTo(
        a.transaction.transactionDate,
      );
    });

    return sorted;
  }

  int _statusPriority(BorrowLendStatus status) {
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
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),

        const SizedBox(height: 10),

        if (items.isEmpty)
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Center(
                child: Text(
                  title == 'Money You Owe'
                      ? 'No borrowed money'
                      : 'No money owed to you',
                ),
              ),
            ),
          )
        else
          ...items.map(
            (item) => _buildBorrowLendItem(
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
    final transaction = item.transaction;

    final counterparty = transaction.counterpartyName?.trim();

    final displayName = counterparty == null || counterparty.isEmpty
        ? 'Unknown Counterparty'
        : counterparty;

    final isBorrowed = transaction.type == 'borrowed';

    final status = item.status();

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) =>
                  TransactionDetailsScreen(transaction: transaction),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    child: Icon(
                      isBorrowed
                          ? Icons.call_received_rounded
                          : Icons.call_made_rounded,
                    ),
                  ),

                  const SizedBox(width: 12),

                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          displayName,
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),

                        Text(isBorrowed ? 'Borrowed' : 'Lent'),
                      ],
                    ),
                  ),

                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: _statusColor(status).withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          _statusLabel(status),
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: _statusColor(status),
                          ),
                        ),
                      ),

                      const SizedBox(height: 6),

                      const Icon(Icons.chevron_right, size: 20),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 16),

              Row(
                children: [
                  Expanded(
                    child: _amountDetail(
                      context: context,
                      label: 'Original',
                      amount: transaction.amount,
                      currency: currency,
                    ),
                  ),

                  Expanded(
                    child: _amountDetail(
                      context: context,
                      label: isBorrowed ? 'Repaid' : 'Received',
                      amount: item.repaidAmount,
                      currency: currency,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              Text(
                isBorrowed ? 'Outstanding' : 'Receivable',
                style: Theme.of(context).textTheme.bodySmall,
              ),

              const SizedBox(height: 2),

              Text(
                CurrencyFormatter.format(
                  amount: item.outstandingAmount,
                  currency: currency,
                ),
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),

              if (transaction.dueDate != null) ...[
                const SizedBox(height: 10),
                Text('Due: ${_formatDate(transaction.dueDate!)}'),
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
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: Theme.of(context).textTheme.bodySmall),
        const SizedBox(height: 2),
        Text(
          CurrencyFormatter.format(amount: amount, currency: currency),
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    final local = date.toLocal();

    return '${local.day.toString().padLeft(2, '0')}/'
        '${local.month.toString().padLeft(2, '0')}/'
        '${local.year}';
  }

  String _statusLabel(BorrowLendStatus status) {
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

  Color _statusColor(BorrowLendStatus status) {
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
