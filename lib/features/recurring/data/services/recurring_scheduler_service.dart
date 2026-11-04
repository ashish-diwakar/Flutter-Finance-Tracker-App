import 'package:finance_tracker/core/utils/calendar_date.dart';
import 'package:finance_tracker/core/services/logger_service.dart';
import 'package:isar_community/isar.dart';
import 'package:uuid/uuid.dart';

import '../../../../shared/models/recurring_transaction_model.dart';
import '../../../../shared/models/transaction_model.dart';

class RecurringSchedulerService {
  final Isar isar;
  final DateTime Function() _clock;

  RecurringSchedulerService(this.isar, {DateTime Function()? clock})
    : _clock = clock ?? DateTime.now;

  Future<int> processRecurringTransactions() async {
    final now = _clock().toUtc();

    final recurring = await isar.recurringTransactionModels
        .filter()
        .isDeletedEqualTo(false)
        .isActiveEqualTo(true)
        .nextRunDateLessThan(now, include: true)
        .findAll();

    if (recurring.isEmpty) {
      return 0;
    }

    final allTransactions = <TransactionModel>[];

    final updatedRecurring = <RecurringTransactionModel>[];

    for (final item in recurring) {
      if (item.interval <= 0 ||
          !const [
            'daily',
            'weekly',
            'monthly',
            'yearly',
          ].contains(item.frequency)) {
        LoggerService.error('Invalid recurring schedule: ${item.uuid}');
        continue;
      }

      while (!item.nextRunDate.isAfter(now)) {
        // =====================================
        // END DATE CHECK
        // =====================================

        if (item.endDate != null &&
            CalendarDate.startOfDay(
              item.nextRunDate,
            ).isAfter(CalendarDate.startOfDay(item.endDate!))) {
          item.isActive = false;

          break;
        }

        final transaction = TransactionModel()
          ..uuid = const Uuid().v4()
          ..amount = item.amount
          ..type = item.type
          ..categoryId = item.categoryId
          ..accountId = item.accountId
          ..notes = item.notes
          ..transactionDate = item.nextRunDate
          ..updatedAt = DateTime.now().toUtc()
          ..isDeleted = false
          ..isSynced = false;

        LoggerService.info(
          'Generated recurring transaction: '
          '${transaction.uuid}',
        );

        allTransactions.add(transaction);

        item.nextRunDate = calculateNextRunDate(item);
      }

      item.updatedAt = DateTime.now().toUtc();

      item.isSynced = false;

      updatedRecurring.add(item);
    }

    await isar.writeTxn(() async {
      if (allTransactions.isNotEmpty) {
        await isar.transactionModels.putAll(allTransactions);
      }

      if (updatedRecurring.isNotEmpty) {
        await isar.recurringTransactionModels.putAll(updatedRecurring);
      }
    });

    LoggerService.info(
      'Recurring Scheduler completed. '
      'Generated ${allTransactions.length} transactions.',
    );
    return allTransactions.length;
  }

  DateTime calculateNextRunDate(RecurringTransactionModel item) {
    return CalendarDate.nextRecurring(
      current: item.nextRunDate,
      anchor: item.startDate,
      frequency: item.frequency,
      interval: item.interval,
    );
  }
}
