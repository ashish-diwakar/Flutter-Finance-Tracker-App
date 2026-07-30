import 'package:finance_tracker/core/utils/currency_formatter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../shared/models/transaction_model.dart';
import '../../../../shared/providers/currency_provider.dart';
import '../screens/transaction_details_screen.dart';
import 'transaction_popup_menu.dart';
import 'transaction_sync_icon.dart';

class TransactionTile extends ConsumerWidget {

  const TransactionTile({

    super.key,

    required this.transaction,

    required this.accountName,

    required this.categoryName,
  });

  final TransactionModel transaction;

  final String accountName;

  final String categoryName;

  @override
  Widget build(
    BuildContext context,
    WidgetRef ref,
  ) {

    final currency =
        ref.watch(
      currencyProvider,
    );

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

        contentPadding:
            const EdgeInsets.symmetric(

          horizontal: 8,

          vertical: 4,
        ),

        onTap: () {

          // Navigate to TransactionDetailsScreen
          Navigator.push(

            context,

            MaterialPageRoute(

              builder: (_) =>
                  TransactionDetailsScreen(

                transaction: transaction,
              ),
            ),
          );
        },

        leading: CircleAvatar(

          backgroundColor:

              isIncome

                  ? Colors.green.shade100

                  : Colors.red.shade100,

          child: Icon(

            isIncome

                ? Icons.trending_up

                : Icons.shopping_bag,

            color:

                isIncome

                    ? Colors.green

                    : Colors.red,
          ),
        ),

        title: Row(

          children: [

            Expanded(

              child: Text(

                categoryName,

                maxLines: 1,

                overflow:
                    TextOverflow.ellipsis,

                style:
                    const TextStyle(

                  fontSize: 16,

                  fontWeight:
                      FontWeight.w600,
                ),
              ),
            ),

            Text(

              CurrencyFormatter.format(

                amount:
                    transaction.amount,

                currency:
                    currency,

                decimalDigits: 0,
              ),

              style: TextStyle(

                fontSize: 16,

                fontWeight:
                    FontWeight.bold,

                color: categoryName ==
                        'Loan'

                    ? Colors.purple

                    : (isIncome

                        ? Colors.green

                        : Colors.red),
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

                  Icons.account_balance_wallet_outlined,

                  size: 15,

                  color: Colors.grey,
                ),

                const SizedBox(
                  width: 4,
                ),

                Expanded(

                  child: Text(

                    accountName,

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

            const SizedBox(
              height: 4,
            ),

            Text(

              categoryName ==
                      'Loan'

                  ? 'Loan'

                  : (isIncome

                      ? 'Income'

                      : 'Expense'),

              style: TextStyle(

                fontSize: 13,

                fontWeight:
                    FontWeight.w500,

                color: categoryName ==
                        'Loan'

                    ? Colors.purple

                    : (isIncome

                        ? Colors.green

                        : Colors.red),
              ),
            ),

            if ((transaction.notes ?? '')
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

                  Icons.calendar_today_outlined,

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
                        .transactionDate,
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

            TransactionSyncIcon(

              isSynced:
                  transaction.isSynced,
            ),

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
}