import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/models/transaction_model.dart';
import '../../../../shared/utils/delete_transaction_helper.dart';
import '../screens/add_transaction_screen.dart';

class TransactionPopupMenu extends ConsumerWidget {
  const TransactionPopupMenu({
    super.key,
    required this.transaction,
  });

  final TransactionModel transaction;

  @override
  Widget build(
    BuildContext context,
    WidgetRef ref,
  ) {
    final canEdit =
        transaction.type != 'repaymentPaid' &&
        transaction.type != 'repaymentReceived';

    return PopupMenuButton<String>(
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints(),
      onSelected: (value) async {
        switch (value) {
          case 'edit':
            if (!canEdit) {
              return;
            }

            await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) =>
                    AddTransactionScreen(
                  transaction: transaction,
                ),
              ),
            );

            break;

          case 'delete':
            await deleteTransaction(
              context: context,
              ref: ref,
              transaction: transaction,
            );

            break;
        }
      },
      itemBuilder: (_) => [
        if (canEdit)
          const PopupMenuItem(
            value: 'edit',
            child: Row(
              children: [
                Icon(
                  Icons.edit_outlined,
                  size: 20,
                ),
                SizedBox(
                  width: 8,
                ),
                Text(
                  'Edit',
                ),
              ],
            ),
          ),
        const PopupMenuItem(
          value: 'delete',
          child: Row(
            children: [
              Icon(
                Icons.delete_outline,
                size: 20,
                color: Colors.red,
              ),
              SizedBox(
                width: 8,
              ),
              Text(
                'Delete',
              ),
            ],
          ),
        ),
      ],
    );
  }
}
