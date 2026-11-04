import 'dart:convert';
import 'dart:ffi';
import 'dart:io';

import 'package:finance_tracker/features/dashboard/data/services/dashboard_insights_service.dart';
import 'package:finance_tracker/features/recurring/data/services/recurring_scheduler_service.dart';
import 'package:finance_tracker/features/reports/data/repositories/reports_repository.dart';
import 'package:finance_tracker/features/transactions/data/repositories/transaction_repository.dart';
import 'package:finance_tracker/shared/models/category_model.dart';
import 'package:finance_tracker/shared/models/recurring_transaction_model.dart';
import 'package:finance_tracker/shared/models/transaction_model.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:isar_community/isar.dart';

void main() {
  late Isar isar;
  late Directory directory;

  setUpAll(() async {
    // Use the native library already installed with the app, without downloads.
    final config = File('.dart_tool/package_config.json');
    final packages =
        jsonDecode(await config.readAsString())['packages'] as List;
    final package = packages.firstWhere(
      (p) => p['name'] == 'isar_community_flutter_libs',
    );
    final root = config.absolute.uri.resolve('${package['rootUri']}/');
    final library = Platform.isWindows
        ? root.resolve('windows/libisar.dll').toFilePath()
        : Platform.isLinux
        ? root.resolve('linux/libisar.so').toFilePath()
        : root.resolve('macos/libisar.dylib').toFilePath();
    await Isar.initializeIsarCore(libraries: {Abi.current(): library});
  });

  setUp(() async {
    directory = await Directory.systemTemp.createTemp('finance_datetime_');
    isar = await Isar.open(
      [
        TransactionModelSchema,
        CategoryModelSchema,
        RecurringTransactionModelSchema,
      ],
      directory: directory.path,
      name: 'datetime_test',
      inspector: false,
    );
  });

  tearDown(() async {
    await isar.close(deleteFromDisk: true);
    await directory.delete(recursive: true);
  });

  TransactionModel transaction(
    String id,
    DateTime date, {
    int amount = 10000,
    String type = 'income',
    bool deleted = false,
  }) => TransactionModel()
    ..uuid = id
    ..transactionDate = date
    ..amount = amount
    ..type = type
    ..accountId = 'account'
    ..isDeleted = deleted;

  test(
    'local midnight, month boundaries, deleted rows and timestamp round trip',
    () async {
      final start = DateTime(2026, 11, 1);
      final end = DateTime(2026, 12, 1);
      final timestamp = DateTime.utc(2026, 10, 31, 18, 30, 0, 123, 456);
      final rows = [
        transaction('before', start.subtract(const Duration(microseconds: 1))),
        transaction('start', start)..createdAt = timestamp,
        transaction('last', end.subtract(const Duration(microseconds: 1))),
        transaction('next', end),
        transaction('deleted', start, deleted: true),
        transaction('expense', start, type: 'expense', amount: 5000),
        transaction('transfer', start, type: 'transfer', amount: 999999),
      ];
      await isar.writeTxn(() => isar.transactionModels.putAll(rows));
      final repository = ReportsRepository(isar);
      final summary = await repository.getMonthlySummary(start);
      expect(summary.income, 20000);
      expect(summary.expense, 5000);
      final saved = await isar.transactionModels.get(rows[1].id);
      expect(saved!.transactionDate, start);
      expect(saved.createdAt.isAtSameMomentAs(timestamp), isTrue);
      final transactions = TransactionRepository(isar);
      await transactions.updateTransaction(saved..notes = 'edited');
      expect(
        (await isar.transactionModels.get(saved.id))!.transactionDate,
        start,
      );
      final insights = await DashboardInsightsService(
        isar,
        clock: () => start,
      ).generateInsights();
      expect(insights.any((i) => i.title == 'Savings This Month'), isTrue);
      expect(
        insights.firstWhere((i) => i.title == 'Savings This Month').description,
        contains('150'),
      );
      await isar.writeTxn(() async {
        await isar.transactionModels.clear();
        await isar.transactionModels.putAll([
          transaction('equal-income', start),
          transaction('equal-expense', start, type: 'expense'),
        ]);
      });
      final zero = await DashboardInsightsService(
        isar,
        clock: () => start,
      ).generateInsights();
      expect(
        zero.any(
          (i) =>
              i.title == 'Savings This Month' ||
              i.title == 'Overspending Alert',
        ),
        isFalse,
      );
    },
  );

  test('upcoming schedules use an exact seven-day instant boundary', () async {
    final now = DateTime(2026, 11, 1);
    final dates = [
      now.subtract(const Duration(microseconds: 1)),
      now.add(const Duration(days: 7)),
      now.add(const Duration(days: 7, microseconds: 1)),
    ];
    final items = List.generate(
      dates.length,
      (i) => RecurringTransactionModel()
        ..uuid = 'upcoming-$i'
        ..amount = 100
        ..type = 'expense'
        ..categoryId = 'c'
        ..accountId = 'a'
        ..frequency = 'monthly'
        ..interval = 1
        ..startDate = dates[i]
        ..nextRunDate = dates[i]
        ..updatedAt = now.toUtc()
        ..isActive = true,
    );
    await isar.writeTxn(() => isar.recurringTransactionModels.putAll(items));
    final insights = await DashboardInsightsService(
      isar,
      clock: () => now,
    ).generateInsights();
    expect(
      insights.singleWhere((i) => i.title == 'Upcoming Recurring').description,
      startsWith('1 recurring'),
    );
  });

  test(
    'recurrence executes exactly at now, includes end day, and is idempotent',
    () async {
      final anchor = DateTime(2024, 1, 31, 9);
      final item = RecurringTransactionModel()
        ..uuid = 'monthly'
        ..amount = 12345
        ..type = 'expense'
        ..categoryId = 'category'
        ..accountId = 'account'
        ..frequency = 'monthly'
        ..interval = 1
        ..startDate = anchor
        ..nextRunDate = anchor.toUtc()
        ..endDate = DateTime(2024, 3, 31)
        ..updatedAt = anchor.toUtc()
        ..isActive = true;
      await isar.writeTxn(() => isar.recurringTransactionModels.put(item));
      final scheduler = RecurringSchedulerService(
        isar,
        clock: () => DateTime(2024, 3, 31, 9),
      );
      expect(await scheduler.processRecurringTransactions(), 3);
      final generated = await isar.transactionModels
          .where()
          .sortByTransactionDate()
          .findAll();
      expect(
        generated
            .map((t) => (t.transactionDate.month, t.transactionDate.day))
            .toList(),
        [(1, 31), (2, 29), (3, 31)],
      );
      expect(
        generated.every(
          (t) => t.amount == 12345 && t.transactionDate.hour == 9,
        ),
        isTrue,
      );
      expect(await scheduler.processRecurringTransactions(), 0);
      // Check the exclusive next instant after the last included end date.
      final later = RecurringSchedulerService(
        isar,
        clock: () => DateTime(2024, 5, 1),
      );
      expect(await later.processRecurringTransactions(), 0);
      expect(
        (await isar.recurringTransactionModels.get(item.id))!.isActive,
        isFalse,
      );
    },
  );
}
