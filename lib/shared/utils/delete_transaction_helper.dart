import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/services/logger_service.dart';
import '../../features/transactions/presentation/providers/transaction_repository_provider.dart';
import '../../features/transactions/presentation/providers/transactions_provider.dart';
import '../../shared/models/transaction_model.dart';
import 'provider_refresh_helper.dart';
import '../../features/borrow_lend/data/services/borrow_lend_notification_service.dart';
import '../../core/utils/currency_formatter.dart';
import '../../shared/providers/currency_provider.dart';

Future<void> deleteTransaction({
  required BuildContext context,
  required WidgetRef ref,
  required TransactionModel transaction,
}) async {
  final isBorrowOrLend =
      transaction.type == 'borrowed' ||
      transaction.type == 'lent';

  final isRepayment =
    transaction.type == 'repaymentPaid' ||
    transaction.type == 'repaymentReceived';

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

  TransactionModel? relatedOriginalTransaction;
  int? restoredOutstandingAmount;

  if (isRepayment) {
    final relatedTransactionId =
        transaction.relatedTransactionId;

    if (relatedTransactionId != null &&
        relatedTransactionId.isNotEmpty) {
      final transactions =
          await ref.read(
        transactionsStreamProvider.future,
      );

      if (!context.mounted) {
        return;
      }

      final matchingOriginals =
          transactions.where(
        (item) =>
            !item.isDeleted &&
            item.uuid ==
                relatedTransactionId &&
            (item.type == 'borrowed' ||
                item.type == 'lent'),
      );

      if (matchingOriginals.isNotEmpty) {
        relatedOriginalTransaction =
            matchingOriginals.first;

        final repaymentType =
            relatedOriginalTransaction.type ==
                    'borrowed'
                ? 'repaymentPaid'
                : 'repaymentReceived';

        var remainingRepaymentTotal = 0;

        for (final item
            in transactions) {
          if (item.isDeleted) {
            continue;
          }

          if (item.uuid ==
              transaction.uuid) {
            continue;
          }

          if (item.relatedTransactionId !=
              relatedOriginalTransaction.uuid) {
            continue;
          }

          if (item.type != repaymentType) {
            continue;
          }

          remainingRepaymentTotal +=
              item.amount;
        }

        final remaining =
            relatedOriginalTransaction.amount -
                remainingRepaymentTotal;

        restoredOutstandingAmount =
            remaining > 0
                ? remaining
                : 0;
      }
    }
  }

  try {
    final repository =
        await ref.read(
      transactionRepositoryProvider.future,
    );

    await repository.deleteTransaction(
      transaction,
    );
    
    // =====================================================
    // RESTORE BORROW / LEND REMINDERS AFTER REPAYMENT DELETE
    // =====================================================

    if (relatedOriginalTransaction != null &&
        restoredOutstandingAmount != null) {
      try {
        final currency =
            ref.read(
          currencyProvider,
        );

        await BorrowLendNotificationService
            .syncReminders(
          transaction:
              relatedOriginalTransaction,
          outstandingAmount:
              restoredOutstandingAmount,
          outstandingAmountText:
              CurrencyFormatter.format(
            amount:
                restoredOutstandingAmount,
            currency: currency,
          ),
        );
      } catch (e, stackTrace) {
        LoggerService.exception(
          'Unable to update Borrow/Lend reminders after repayment delete',
          e,
          stackTrace,
        );
      }
    }

    // =====================================================
    // CANCEL BORROW / LEND REMINDERS
    // =====================================================

    if (isBorrowOrLend) {
      try {
        await BorrowLendNotificationService
            .cancelReminders(
          transaction.uuid,
        );
      } catch (e, stackTrace) {
        LoggerService.exception(
          'Unable to cancel Borrow/Lend reminders after delete',
          e,
          stackTrace,
        );
      }
    }

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
