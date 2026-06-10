import 'package:isar_community/isar.dart';

import '../../../../shared/models/recurring_transaction_model.dart';
import '../../../../shared/models/transaction_model.dart';

class RecurringSchedulerService {

  final Isar isar;

  RecurringSchedulerService(
    this.isar,
  );

  Future<void>
      processRecurringTransactions()
  async {

    final now =
        DateTime.now();

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

    for (final item
        in recurring) {

      while (
          item.nextRunDate
              .isBefore(now)) {

        // Stop processing if recurring
        // has crossed its end date.
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

              ..uuid = DateTime.now().toIso8601String()
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
                  DateTime.now()

              ..isDeleted =
                  false

              ..isSynced =
                  false;

        await isar.writeTxn(
          () async {

            await isar
                .transactionModels
                .put(
              transaction,
            );
          },
        );

        item.nextRunDate =
            calculateNextRunDate(
          item,
        );
      }

      item.updatedAt =
          DateTime.now();

      item.isSynced =
          false;

      await isar.writeTxn(
        () async {

          await isar
              .recurringTransactionModels
              .put(item);
        },
      );
    }
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