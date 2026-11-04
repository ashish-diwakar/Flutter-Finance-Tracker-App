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
  String? categoryName,
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

  final currency = ref.read(currencyProvider);
  final amountPrefix = switch (transaction.type) {
    'income' || 'borrowed' || 'repaymentReceived' => '+',
    'expense' || 'lent' || 'repaymentPaid' => '-',
    _ => '',
  };
  final transactionTypeLabel = switch (transaction.type) {
    'income' => 'Income',
    'expense' => 'Expense',
    'transfer' => 'Transfer',
    'borrowed' => 'Borrowed',
    'lent' => 'Lent',
    'repaymentPaid' => 'Repayment Paid',
    'repaymentReceived' => 'Repayment Received',
    _ => transaction.type,
  };
  final normalizedCategoryName = categoryName?.trim();
  final counterpartyName = transaction.counterpartyName?.trim();
  final amountColor = switch (amountPrefix) {
    '+' => const Color(0xFF17664F),
    '-' => const Color(0xFFB54C44),
    _ => const Color(0xFF244D40),
  };
  final amountText =
      '$amountPrefix${CurrencyFormatter.format(
        amount: transaction.amount,
        currency: currency,
        decimalDigits: transaction.amount % 100 == 0 ? 0 : 2,
      )}';

  final confirmed =
      await showDialog<bool>(
    context: context,
    builder: (dialogContext) {
      return AlertDialog(
        backgroundColor: const Color(0xFFF3FAF5),
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        constraints: const BoxConstraints(maxWidth: 440),
        insetPadding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 24,
        ),
        scrollable: true,
        titlePadding: const EdgeInsets.fromLTRB(20, 24, 20, 8),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 12,
        ),
        actionsPadding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
        actionsOverflowButtonSpacing: 8,
        title: const Row(
          children: [
            DecoratedBox(
              decoration: BoxDecoration(
                color: Color(0xFFFBE6E3),
                borderRadius: BorderRadius.all(Radius.circular(12)),
              ),
              child: SizedBox(
                width: 44,
                height: 44,
                child: Icon(Icons.delete_outline, color: Color(0xFFB54C44)),
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: Text(
                'Delete Transaction?',
                style: TextStyle(
                  color: Color(0xFF315F53),
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        content: SizedBox(
          width: 440,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFFE5F1E9),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Column(
                  children: [
                    _TransactionDeleteDetailRow(
                      label: 'Transaction Type',
                      value: transactionTypeLabel,
                    ),
                    if (normalizedCategoryName != null &&
                        normalizedCategoryName.isNotEmpty) ...[
                      const Divider(height: 20, color: Color(0xFFC9DBD0)),
                      _TransactionDeleteDetailRow(
                        label: 'Category',
                        value: normalizedCategoryName,
                      ),
                    ],
                    if (counterpartyName != null &&
                        counterpartyName.isNotEmpty) ...[
                      const Divider(height: 20, color: Color(0xFFC9DBD0)),
                      _TransactionDeleteDetailRow(
                        label: 'Counterparty',
                        value: counterpartyName,
                      ),
                    ],
                    const Divider(height: 20, color: Color(0xFFC9DBD0)),
                    _TransactionDeleteDetailRow(
                      label: 'Amount',
                      value: amountText,
                      valueColor: amountColor,
                      prominent: true,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              const Text(
                'Are you sure you want to delete this transaction?',
                style: TextStyle(
                  color: Color(0xFF244C40),
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(
                dialogContext,
                false,
              );
            },
            style: TextButton.styleFrom(
              foregroundColor: const Color(0xFF315F53),
              minimumSize: const Size(88, 48),
              side: const BorderSide(color: Color(0xFFB5D9CA)),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              textStyle: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            child: const Text(
              'Cancel',
            ),
          ),
          FilledButton.icon(
            onPressed: () {
              Navigator.pop(
                dialogContext,
                true,
              );
            },
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFFB54C44),
              foregroundColor: Colors.white,
              minimumSize: const Size(104, 48),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              textStyle: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            icon: const Icon(Icons.delete_outline),
            label: const Text(
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

class _TransactionDeleteDetailRow extends StatelessWidget {
  const _TransactionDeleteDetailRow({
    required this.label,
    required this.value,
    this.valueColor = const Color(0xFF244D40),
    this.prominent = false,
  });

  final String label;
  final String value;
  final Color valueColor;
  final bool prominent;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 4,
          child: Text(
            label,
            style: const TextStyle(
              color: Color(0xFF607C70),
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          flex: 6,
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: TextStyle(
              color: valueColor,
              fontSize: prominent ? 18 : 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}
