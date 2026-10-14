import '../../../../core/services/notification_service.dart';
import '../../../../shared/models/transaction_model.dart';
import '../../../../core/config/currency_config.dart';
import '../../../../core/services/logger_service.dart';
import '../../../../core/utils/currency_formatter.dart';

class BorrowLendNotificationService {
  static Future<void> syncReminders({
    required TransactionModel transaction,
    required int outstandingAmount,
    required String outstandingAmountText,
  }) async {
    await cancelReminders(
      transaction.uuid,
    );

    if (transaction.type != 'borrowed' &&
        transaction.type != 'lent') {
      return;
    }

    if (outstandingAmount <= 0) {
      return;
    }

    final dueDate =
        transaction.dueDate;

    if (dueDate == null) {
      return;
    }

    final localDueDate =
        dueDate.toLocal();

    final dueAt = DateTime(
      localDueDate.year,
      localDueDate.month,
      localDueDate.day,
      9,
    );

    final dayBefore =
        dueAt.subtract(
      const Duration(
        days: 1,
      ),
    );

    final counterparty =
        transaction
            .counterpartyName
            ?.trim();

    final displayName =
        counterparty == null ||
                counterparty.isEmpty
            ? transaction.type ==
                    'borrowed'
                ? 'the lender'
                : 'the borrower'
            : counterparty;

    final baseId =
        _notificationBaseId(
      transaction.uuid,
    );

    if (transaction.type ==
        'borrowed') {
      await NotificationService
          .scheduleNotification(
        id: baseId,
        title:
            'Repayment due tomorrow',
        body:
            '$outstandingAmountText repayment to '
            '$displayName is due tomorrow.',
        scheduledAt:
            dayBefore,
        payload:
            'borrow_lend:${transaction.uuid}',
      );

      await NotificationService
          .scheduleNotification(
        id: baseId + 1,
        title:
            'Repayment due today',
        body:
            '$outstandingAmountText repayment to '
            '$displayName is due today.',
        scheduledAt:
            dueAt,
        payload:
            'borrow_lend:${transaction.uuid}',
      );
    } else {
      await NotificationService
          .scheduleNotification(
        id: baseId,
        title:
            'Money due tomorrow',
        body:
            '$outstandingAmountText from '
            '$displayName is due tomorrow.',
        scheduledAt:
            dayBefore,
        payload:
            'borrow_lend:${transaction.uuid}',
      );

      await NotificationService
          .scheduleNotification(
        id: baseId + 1,
        title:
            'Money due today',
        body:
            '$outstandingAmountText from '
            '$displayName is due today.',
        scheduledAt:
            dueAt,
        payload:
            'borrow_lend:${transaction.uuid}',
      );
    }
  }

  static Future<void> syncAllReminders({
    required List<TransactionModel> transactions,
    required CurrencyConfig currency,
  }) async {
    final activeTransactions =
        transactions
            .where(
              (transaction) =>
                  !transaction.isDeleted,
            )
            .toList();

    for (final transaction
        in transactions) {
      if (transaction.type != 'borrowed' &&
          transaction.type != 'lent') {
        continue;
      }

      try {
        if (transaction.isDeleted) {
          await cancelReminders(
            transaction.uuid,
          );

          continue;
        }

        final repaymentType =
            transaction.type == 'borrowed'
                ? 'repaymentPaid'
                : 'repaymentReceived';

        var repaidAmount = 0;

        for (final repayment
            in activeTransactions) {
          if (repayment.relatedTransactionId !=
              transaction.uuid) {
            continue;
          }

          if (repayment.type !=
              repaymentType) {
            continue;
          }

          repaidAmount +=
              repayment.amount;
        }

        final remaining =
            transaction.amount -
                repaidAmount;

        final outstandingAmount =
            remaining > 0
                ? remaining
                : 0;

        await syncReminders(
          transaction: transaction,
          outstandingAmount:
              outstandingAmount,
          outstandingAmountText:
              CurrencyFormatter.format(
            amount:
                outstandingAmount,
            currency:
                currency,
          ),
        );
      } catch (e, stackTrace) {
        LoggerService.exception(
          'Unable to reconcile Borrow/Lend reminder for ${transaction.uuid}',
          e,
          stackTrace,
        );
      }
    }
  }

  static Future<void> cancelReminders(
    String transactionUuid,
  ) async {
    final baseId =
        _notificationBaseId(
      transactionUuid,
    );

    await NotificationService
        .cancelNotification(
      id: baseId,
    );

    await NotificationService
        .cancelNotification(
      id: baseId + 1,
    );
  }

  static int _notificationBaseId(
    String uuid,
  ) {
    var hash = 17;

    for (final codeUnit
        in uuid.codeUnits) {
      hash =
          ((hash * 31) +
                  codeUnit) &
              0x3fffffff;
    }

    return hash * 2;
  }
}