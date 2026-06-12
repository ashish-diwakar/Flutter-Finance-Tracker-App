import 'package:finance_tracker/core/services/logger_service.dart';
import 'package:isar_community/isar.dart';
import 'package:uuid/uuid.dart';

import '../../../../shared/models/recurring_transaction_model.dart';
import '../../../../shared/models/transaction_model.dart';

class RecurringSchedulerService {

  final Isar isar;

  RecurringSchedulerService(
    this.isar,
  );

  Future<int>
      processRecurringTransactions()
  async {

    final now =
        DateTime.now().toUtc();

    final recurring =
        await isar
            .recurringTransactionModels
            .filter()
            .isDeletedEqualTo(false)
            .isActiveEqualTo(true)
            .nextRunDateLessThan(
              now,
            )
            .findAll();

    if (recurring.isEmpty) {
      return 0;
    }

    final allTransactions =
        <TransactionModel>[];

    final updatedRecurring =
        <RecurringTransactionModel>[];

    for (final item
        in recurring) {

      while (
        !item.nextRunDate.isAfter(
          now,
        )
      ) {

        // =====================================
        // END DATE CHECK
        // =====================================

        if (item.endDate != null &&
            item.nextRunDate.isAfter(
              item.endDate!,
            )) {

          item.isActive =
              false;

          break;
        }

        final transaction =
            TransactionModel()

              ..uuid =
                  const Uuid().v4()

              ..amount =
                  item.amount

              ..type =
                  item.type

              ..categoryId =
                  item.categoryId

              ..accountId =
                  item.accountId

              ..notes =
                  item.notes

              ..transactionDate =
                  item.nextRunDate

              ..updatedAt =
                  DateTime.now().toUtc()

              ..isDeleted =
                  false

              ..isSynced =
                  false;

        LoggerService.info(
          'Generated recurring transaction: '
          '${transaction.uuid}',
        );

        allTransactions.add(
          transaction,
        );

        item.nextRunDate =
            calculateNextRunDate(
          item,
        );
      }

      item.updatedAt =
          DateTime.now().toUtc();

      item.isSynced =
          false;

      updatedRecurring.add(
        item,
      );
    }

    await isar.writeTxn(
      () async {

        if (allTransactions
            .isNotEmpty) {

          await isar
              .transactionModels
              .putAll(
            allTransactions,
          );
        }

        if (updatedRecurring
            .isNotEmpty) {

          await isar
              .recurringTransactionModels
              .putAll(
            updatedRecurring,
          );
        }
      },
    );

    LoggerService.info(
      'Recurring Scheduler completed. '
      'Generated ${allTransactions.length} transactions.',
    );
    return allTransactions.length;
  }

  DateTime calculateNextRunDate(
    RecurringTransactionModel item,
  ) {

    switch (
        item.frequency) {

      case 'daily':

        return item.nextRunDate
            .add(
          Duration(
            days:
                item.interval,
          ),
        );

      case 'weekly':

        return item.nextRunDate
            .add(
          Duration(
            days:
                7 *
                item.interval,
          ),
        );

      case 'monthly':

        return DateTime(

          item.nextRunDate.year,

          item.nextRunDate.month +
              item.interval,

          item.nextRunDate.day,
        );

      case 'yearly':

        return DateTime(

          item.nextRunDate.year +
              item.interval,

          item.nextRunDate.month,

          item.nextRunDate.day,
        );

      default:

        return item.nextRunDate;
    }
  }
}