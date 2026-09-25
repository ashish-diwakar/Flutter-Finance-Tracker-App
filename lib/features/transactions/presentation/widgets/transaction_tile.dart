import 'package:finance_tracker/core/utils/currency_formatter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../shared/models/transaction_model.dart';
import '../../../../shared/providers/currency_provider.dart';
import '../screens/transaction_details_screen.dart';
import 'transaction_popup_menu.dart';

class TransactionTile extends ConsumerWidget {
  const TransactionTile({
    super.key,
    required this.transaction,
    required this.accountName,
    this.toAccountName,
    this.categoryName,
  });

  final TransactionModel transaction;
  final String accountName;
  final String? toAccountName;
  final String? categoryName;

  @override
  Widget build(
    BuildContext context,
    WidgetRef ref,
  ) {
    final currency =
        ref.watch(
      currencyProvider,
    );

    final presentation =
        _presentationFor(
      transaction,
      categoryName,
    );

    return Card(
      margin:
          const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 4,
      ),
      child: ListTile(
        contentPadding:
            const EdgeInsets.symmetric(
          horizontal: 8,
          vertical: 4,
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
        leading: CircleAvatar(
          backgroundColor:
              presentation.color
                  .withValues(
            alpha: 0.12,
          ),
          child: Icon(
            presentation.icon,
            color:
                presentation.color,
          ),
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                presentation.title,
                maxLines: 1,
                overflow:
                    TextOverflow.ellipsis,
                style:
                    TextStyle(
                  fontSize: 16,
                  fontWeight:
                      FontWeight.w600,
                  color:
                      presentation.color,
                ),
              ),
            ),
            Text(
              '${presentation.prefix}'
              '${CurrencyFormatter.format(
                amount:
                    transaction.amount,
                currency:
                    currency,
                decimalDigits: 0,
              )}',
              style: TextStyle(
                fontSize: 16,
                fontWeight:
                    FontWeight.bold,
                color:
                    presentation.color,
              ),
            ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            const SizedBox(
              height: 6,
            ),
            Row(
              children: [
                const Icon(
                  Icons
                      .account_balance_wallet_outlined,
                  size: 15,
                  color: Colors.grey,
                ),
                const SizedBox(
                  width: 4,
                ),
                Expanded(
                  child: Text(
                    _accountText(),
                    maxLines: 1,
                    overflow:
                        TextOverflow
                            .ellipsis,
                    style:
                        const TextStyle(
                      fontSize: 13,
                      color:
                          Colors.black87,
                    ),
                  ),
                ),
              ],
            ),
            if ((transaction
                        .counterpartyName ??
                    '')
                .trim()
                .isNotEmpty) ...[
              const SizedBox(
                height: 4,
              ),
              Row(
                children: [
                  const Icon(
                    Icons
                        .person_outline,
                    size: 14,
                    color: Colors.grey,
                  ),
                  const SizedBox(
                    width: 4,
                  ),
                  Expanded(
                    child: Text(
                      _counterpartyText(),
                      maxLines: 1,
                      overflow:
                          TextOverflow
                              .ellipsis,
                      style:
                          const TextStyle(
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
            ],
            if ((transaction.notes ??
                    '')
                .trim()
                .isNotEmpty) ...[
              const SizedBox(
                height: 4,
              ),
              Text(
                transaction.notes!,
                maxLines: 2,
                overflow:
                    TextOverflow.ellipsis,
                style:
                    const TextStyle(
                  fontSize: 13,
                ),
              ),
            ],
            const SizedBox(
              height: 4,
            ),
            Row(
              children: [
                const Icon(
                  Icons
                      .calendar_today_outlined,
                  size: 13,
                  color: Colors.grey,
                ),
                const SizedBox(
                  width: 4,
                ),
                Text(
                  DateFormat(
                    'dd MMM yyyy',
                  ).format(
                    transaction
                        .transactionDate
                        .toLocal(),
                  ),
                  style:
                      const TextStyle(
                    fontSize: 12,
                    color:
                        Colors.grey,
                  ),
                ),
              ],
            ),
          ],
        ),
        trailing: Row(
          mainAxisSize:
              MainAxisSize.min,
          children: [
            const SizedBox(
              width: 4,
            ),
            TransactionPopupMenu(
              transaction:
                  transaction,
            ),
          ],
        ),
      ),
    );
  }

  String _accountText() {
    if (transaction.type ==
        'transfer') {
      final destination =
          toAccountName ??
              'Unknown Account';

      return '$accountName → '
          '$destination';
    }

    return accountName;
  }

  String _counterpartyText() {
    final name =
        transaction.counterpartyName!
            .trim();

    switch (transaction.type) {
      case 'borrowed':
        return 'Borrowed from $name';

      case 'lent':
        return 'Lent to $name';

      case 'repaymentPaid':
        return 'Paid to $name';

      case 'repaymentReceived':
        return 'Received from $name';

      default:
        return name;
    }
  }

  static _TransactionTilePresentation
      _presentationFor(
    TransactionModel transaction,
    String? categoryName,
  ) {
    switch (transaction.type) {
      case 'income':
        return _TransactionTilePresentation(
          title:
              categoryName ?? 'Income',
          prefix: '+',
          color: Colors.green,
          icon: Icons.trending_up,
        );

      case 'expense':
        return _TransactionTilePresentation(
          title:
              categoryName ?? 'Expense',
          prefix: '-',
          color: Colors.red,
          icon: Icons.shopping_bag,
        );

      case 'transfer':
        return const _TransactionTilePresentation(
          title: 'Transfer',
          prefix: '',
          color: Colors.blue,
          icon:
              Icons.swap_horiz_rounded,
        );

      case 'borrowed':
        return const _TransactionTilePresentation(
          title: 'Borrowed',
          prefix: '+',
          color: Colors.green,
          icon:
              Icons.call_received_rounded,
        );

      case 'lent':
        return const _TransactionTilePresentation(
          title: 'Lent',
          prefix: '-',
          color: Colors.orange,
          icon:
              Icons.call_made_rounded,
        );

      case 'repaymentPaid':
        return const _TransactionTilePresentation(
          title: 'Repayment Paid',
          prefix: '-',
          color: Colors.red,
          icon:
              Icons.outbound_outlined,
        );

      case 'repaymentReceived':
        return const _TransactionTilePresentation(
          title: 'Repayment Received',
          prefix: '+',
          color: Colors.green,
          icon: Icons
              .move_to_inbox_outlined,
        );

      default:
        return _TransactionTilePresentation(
          title:
              categoryName ??
                  'Transaction',
          prefix: '',
          color:
              Colors.blueGrey,
          icon: Icons
              .receipt_long_outlined,
        );
    }
  }
}

class _TransactionTilePresentation {
  final String title;
  final String prefix;
  final Color color;
  final IconData icon;

  const _TransactionTilePresentation({
    required this.title,
    required this.prefix,
    required this.color,
    required this.icon,
  });
}
