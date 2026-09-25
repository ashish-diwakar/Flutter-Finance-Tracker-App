import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/services/logger_service.dart';
import '../../features/transactions/presentation/providers/transaction_repository_provider.dart';
import '../../features/transactions/presentation/providers/transactions_provider.dart';
import '../../shared/models/transaction_model.dart';
import 'provider_refresh_helper.dart';

Future<void> deleteTransaction({
  required BuildContext context,
  required WidgetRef ref,
  required TransactionModel transaction,
}) async {
  final isBorrowOrLend =
      transaction.type == 'borrowed' ||
      transaction.type == 'lent';

  if (isBorrowOrLend) {
    final transactions =
        await ref.read(
      transactionsStreamProvider.future,
    );

    if (!context.mounted) {
      return;
    }

    final hasLinkedRepayments =
        transactions.any(
      (item) =>
          !item.isDeleted &&
          item.relatedTransactionId ==
              transaction.uuid,
    );

    if (hasLinkedRepayments) {
      await showDialog<void>(
        context: context,
        builder: (dialogContext) {
          return AlertDialog(
            title: const Text(
              'Cannot Delete Transaction',
            ),
            content: Text(
              transaction.type == 'borrowed'
                  ? 'This borrowed transaction has recorded repayments. '
                      'Delete its repayment transactions first, then delete the borrowed transaction.'
                  : 'This lent transaction has recorded repayments. '
                      'Delete its repayment transactions first, then delete the lent transaction.',
            ),
            actions: [
              FilledButton(
                onPressed: () {
                  Navigator.pop(
                    dialogContext,
                  );
                },
                child: const Text(
                  'OK',
                ),
              ),
            ],
          );
        },
      );

      return;
    }
  }

  if (!context.mounted) {
    return;
  }

  final confirmed =
      await showDialog<bool>(
    context: context,
    builder: (dialogContext) {
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
                dialogContext,
                false,
              );
            },
            child: const Text(
              'Cancel',
            ),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(
                dialogContext,
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

  if (confirmed != true) {
    return;
  }

  try {
    final repository =
        await ref.read(
      transactionRepositoryProvider.future,
    );

    await repository.deleteTransaction(
      transaction,
    );

    await ProviderRefreshHelper
        .refreshAllFinancialData(
      ref,
    );

    if (context.mounted) {
      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content: Text(
            'Transaction deleted successfully.',
          ),
        ),
      );
    }
  } catch (e, stackTrace) {
    LoggerService.exception(
      'Delete Transaction',
      e,
      stackTrace,
    );

    if (context.mounted) {
      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content: Text(
            'Unable to delete transaction.',
          ),
        ),
      );
    }
  }
}
