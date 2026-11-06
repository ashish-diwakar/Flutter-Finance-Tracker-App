import 'dart:convert';
import 'dart:ffi';
import 'dart:io';

import 'package:finance_tracker/core/database/database_initializer.dart';
import 'package:finance_tracker/core/services/app_settings_service.dart';
import 'package:finance_tracker/features/accounts/domain/services/account_balance_service.dart';
import 'package:finance_tracker/features/backup/data/repositories/backup_repository.dart';
import 'package:finance_tracker/features/backup/domain/services/backup_v2_preflight.dart';
import 'package:finance_tracker/shared/models/account_model.dart';
import 'package:finance_tracker/shared/models/category_model.dart';
import 'package:finance_tracker/shared/models/financial_goal_model.dart';
import 'package:finance_tracker/shared/models/investment_model.dart';
import 'package:finance_tracker/shared/models/recurring_transaction_model.dart';
import 'package:finance_tracker/shared/models/transaction_model.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:isar_community/isar.dart';
import 'package:shared_preferences/shared_preferences.dart';

String _uuid(int value) =>
    '00000000-0000-4000-8000-${value.toString().padLeft(12, '0')}';

Map<String, dynamic> _account(
  int id, {
  int balance = 1234567890123,
  bool isArchived = false,
  bool isDeleted = false,
}) => {
  'id': _uuid(id),
  'name': 'Synthetic account $id',
  'type': 'cash',
  'currentBalance': balance,
  'isArchived': isArchived,
  'isDefault': false,
  'createdAt': '2026-01-01T00:00:00.000Z',
  'updatedAt': '2026-01-02T00:00:00.000Z',
  'isDeleted': isDeleted,
};

Map<String, dynamic> _category(int id, String type, {bool isDeleted = false}) =>
    {
      'id': _uuid(id),
      'name': 'Synthetic $type category',
      'type': type,
      'icon': 'category',
      'colorValue': 4279383126,
      'isDefault': false,
      'createdAt': '2026-01-01T00:00:00.000Z',
      'updatedAt': null,
      'isDeleted': isDeleted,
      'monthlyBudget': 987654321,
    };

Map<String, dynamic> _transaction(
  int id,
  String type,
  int accountId, {
  int? categoryId,
  int? toAccountId,
  int? relatedId,
  bool isDeleted = false,
  int amount = 100,
}) => {
  'id': _uuid(id),
  'amount': amount,
  'type': type,
  'categoryId': categoryId == null ? null : _uuid(categoryId),
  'accountId': _uuid(accountId),
  'toAccountId': toAccountId == null ? null : _uuid(toAccountId),
  'counterpartyName': type == 'borrowed' || type == 'lent'
      ? 'Synthetic counterparty'
      : null,
  'relatedTransactionId': relatedId == null ? null : _uuid(relatedId),
  'dueDate': type == 'borrowed' || type == 'lent'
      ? '2027-01-01T00:00:00.000Z'
      : null,
  'notes': 'Synthetic transaction',
  'transactionDate': '2026-02-01T00:00:00.000Z',
  'createdAt': '2026-02-01T00:00:00.000Z',
  'updatedAt': null,
  'isDeleted': isDeleted,
};

Map<String, dynamic> _document({required int base, bool populated = true}) {
  final accounts = populated
      ? [
          _account(base + 1, balance: 9007199254740991),
          _account(
            base + 2,
            balance: -7654321,
            isArchived: true,
            isDeleted: true,
          ),
        ]
      : <Map<String, dynamic>>[];
  final categories = populated
      ? [
          _category(base + 3, 'income'),
          _category(base + 4, 'expense', isDeleted: true),
        ]
      : <Map<String, dynamic>>[];
  final transactions = populated
      ? [
          _transaction(
            base + 5,
            'income',
            base + 1,
            categoryId: base + 3,
            amount: 9007199254740991,
          ),
          _transaction(
            base + 6,
            'expense',
            base + 1,
            categoryId: base + 4,
            amount: 250,
          ),
          _transaction(
            base + 7,
            'transfer',
            base + 1,
            toAccountId: base + 2,
            amount: 300,
          ),
          _transaction(
            base + 8,
            'borrowed',
            base + 1,
            isDeleted: true,
            amount: 500,
          ),
          _transaction(
            base + 9,
            'repaymentPaid',
            base + 2,
            relatedId: base + 8,
            amount: 100,
          ),
          _transaction(base + 10, 'lent', base + 2, amount: 600),
          _transaction(
            base + 11,
            'repaymentReceived',
            base + 1,
            relatedId: base + 10,
            amount: 200,
          ),
        ]
      : <Map<String, dynamic>>[];
  final recurring = populated
      ? [
          {
            'id': _uuid(base + 12),
            'amount': 4321,
            'type': 'expense',
            'categoryId': _uuid(base + 4),
            'accountId': _uuid(base + 1),
            'notes': 'Synthetic recurring schedule',
            'startDate': '2025-01-01T00:00:00.000Z',
            'endDate': '2030-01-01T00:00:00.000Z',
            'frequency': 'monthly',
            'interval': 3,
            'isActive': true,
            'nextRunDate': '2020-06-15T00:00:00.000Z',
            'updatedAt': '2026-01-03T00:00:00.000Z',
            'isDeleted': false,
          },
        ]
      : <Map<String, dynamic>>[];
  final goals = populated
      ? [
          {
            'id': _uuid(base + 13),
            'name': 'Synthetic goal',
            'description': 'Progress is preserved',
            'targetAmount': 9876543210,
            'currentAmount': 1234567890,
            'linkedAccountId': _uuid(base + 2),
            'targetDate': '2029-12-31T00:00:00.000Z',
            'createdAt': '2026-01-01T00:00:00.000Z',
            'updatedAt': '2026-01-03T00:00:00.000Z',
            'isCompleted': false,
            'isDeleted': true,
          },
        ]
      : <Map<String, dynamic>>[];
  final investments = populated
      ? [
          {
            'id': _uuid(base + 14),
            'name': 'Synthetic fixed deposit',
            'type': 'FD',
            'symbol': 'FD-SYNTH',
            'notes': 'No financial account is linked',
            'quantity': 1,
            'purchasePrice': 9007199254740991,
            'currentPrice': 9007199254740992,
            'purchaseDate': '2024-01-01T00:00:00.000Z',
            'createdAt': '2024-01-01T00:00:00.000Z',
            'updatedAt': '2026-01-03T00:00:00.000Z',
            'interestRate': 7.123456789012345,
            'maturityDate': '2030-01-01T00:00:00.000Z',
            'maturityValue': 9007199254740993,
            'investmentClass': 'fixed',
            'isDeleted': true,
          },
        ]
      : <Map<String, dynamic>>[];

  final collections = {
    'accounts': accounts,
    'categories': categories,
    'transactions': transactions,
    'recurringTransactions': recurring,
    'financialGoals': goals,
    'investments': investments,
  };
  return {
    'format': 'finance-tracker-backup',
    'schemaVersion': 2,
    'metadata': {
      'exportedAt': '2026-11-06T00:00:00.000Z',
      'appVersion': null,
      'currencyCode': 'EUR',
    },
    'manifest': {
      for (final entry in collections.entries)
        entry.key: {'recordCount': entry.value.length},
    },
    'collections': collections,
  };
}

ValidatedBackupRestorePlan _plan(int base, {bool populated = true}) =>
    BackupV2Preflight.parse(
      jsonEncode(_document(base: base, populated: populated)),
    );

Map<String, dynamic> _collectionsFrom(String json) =>
    (jsonDecode(json) as Map<String, dynamic>)['collections']
        as Map<String, dynamic>;

void main() {
  late Isar isar;
  late Directory directory;

  setUpAll(() async {
    final config = File('.dart_tool/package_config.json');
    final packages =
        jsonDecode(await config.readAsString())['packages'] as List;
    final package = packages.firstWhere(
      (entry) => entry['name'] == 'isar_community_flutter_libs',
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
    SharedPreferences.setMockInitialValues({'selected_currency': 'JPY'});
    directory = await Directory.systemTemp.createTemp('finance_v2_restore_');
    isar = await Isar.open(
      [
        AccountModelSchema,
        CategoryModelSchema,
        TransactionModelSchema,
        RecurringTransactionModelSchema,
        FinancialGoalModelSchema,
        InvestmentModelSchema,
      ],
      directory: directory.path,
      name: 'v2_restore_test',
      inspector: false,
    );
  });

  tearDown(() async {
    await isar.close(deleteFromDisk: true);
    await directory.delete(recursive: true);
  });

  Future<String> snapshot() => BackupRepository(isar).generateBackupJson();

  Future<void> expectCollections(Map<String, dynamic> expected) async {
    expect(_collectionsFrom(await snapshot()), equals(expected));
  }

  test('restores all six collections into an empty database', () async {
    final plan = _plan(1000);
    final result = await BackupRepository(isar).restoreVersion2Backup(plan);

    expect(result.succeeded, isTrue);
    expect(result.errorMessage, isNull);
    expect(
      result.warnings,
      contains(
        'Provider caches and device-local borrow/lend reminders require post-commit reconciliation.',
      ),
    );
    expect(result.restoredCounts, {
      'accounts': 2,
      'categories': 2,
      'transactions': 7,
      'recurringTransactions': 1,
      'financialGoals': 1,
      'investments': 1,
    });

    final restored = await snapshot();
    final collections = _collectionsFrom(restored);
    final accounts = await isar.accountModels.where().findAll();
    final categories = await isar.categoryModels.where().findAll();
    final transactions = await isar.transactionModels.where().findAll();
    final recurring = await isar.recurringTransactionModels.where().findAll();
    final goals = await isar.financialGoalModels.where().findAll();
    final investments = await isar.investmentModels.where().findAll();

    expect(accounts.map((item) => item.uuid).toSet(), {
      _uuid(1001),
      _uuid(1002),
    });
    expect(categories.map((item) => item.uuid).toSet(), {
      _uuid(1003),
      _uuid(1004),
    });
    expect(transactions.map((item) => item.uuid).toSet(), {
      _uuid(1005),
      _uuid(1006),
      _uuid(1007),
      _uuid(1008),
      _uuid(1009),
      _uuid(1010),
      _uuid(1011),
    });

    final transfer = transactions.singleWhere(
      (item) => item.type == 'transfer',
    );
    expect(transfer.accountId, _uuid(1001));
    expect(transfer.toAccountId, _uuid(1002));
    expect(transactions.where((item) => item.type == 'transfer'), hasLength(1));
    expect(
      transactions
          .singleWhere((item) => item.type == 'repaymentPaid')
          .relatedTransactionId,
      _uuid(1008),
    );
    expect(
      transactions
          .singleWhere((item) => item.type == 'repaymentReceived')
          .relatedTransactionId,
      _uuid(1010),
    );
    expect(
      transactions.singleWhere((item) => item.type == 'income').categoryId,
      _uuid(1003),
    );

    expect(
      accounts.firstWhere((item) => item.uuid == _uuid(1001)).currentBalance,
      9007199254740991,
    );
    final archivedAccount = accounts.singleWhere(
      (item) => item.uuid == _uuid(1002),
    );
    expect(archivedAccount.isArchived, isTrue);
    expect(archivedAccount.isDeleted, isTrue);
    expect(
      categories.singleWhere((item) => item.uuid == _uuid(1004)).isDeleted,
      isTrue,
    );
    expect(recurring.single.uuid, _uuid(1012));
    expect(recurring.single.accountId, _uuid(1001));
    expect(recurring.single.categoryId, _uuid(1004));
    expect(recurring.single.frequency, 'monthly');
    expect(recurring.single.interval, 3);
    expect(recurring.single.nextRunDate.toUtc(), DateTime.utc(2020, 6, 15));
    expect(recurring.single.isActive, isTrue);
    expect(goals.single.currentAmount, 1234567890);
    expect(goals.single.uuid, _uuid(1013));
    expect(goals.single.linkedAccountId, _uuid(1002));
    expect(goals.single.isDeleted, isTrue);
    expect(investments.single.purchasePrice, 9007199254740991);
    expect(investments.single.currentPrice, 9007199254740992);
    expect(investments.single.uuid, _uuid(1014));
    expect(investments.single.maturityValue, 9007199254740993);
    expect(
      investments.single.interestRate,
      closeTo(7.123456789012345, 0.000000000000001),
    );
    expect(investments.single.isDeleted, isTrue);
    expect(accounts.every((item) => !item.isSynced), isTrue);
    expect(categories.every((item) => !item.isSynced), isTrue);
    expect(transactions.every((item) => !item.isSynced), isTrue);
    expect(recurring.every((item) => !item.isSynced), isTrue);
    expect(goals.every((item) => !item.isSynced), isTrue);
    expect(investments.every((item) => !item.isSynced), isTrue);

    final source = plan.accounts.firstWhere((item) => item.uuid == _uuid(1001));
    final sourceTransactions = plan.transactions;
    final restoredTransactions = transactions;
    final restoredBalance = AccountBalanceService.calculate(
      account: accounts.firstWhere((item) => item.uuid == _uuid(1001)),
      transactions: restoredTransactions,
    );
    expect(
      restoredBalance,
      AccountBalanceService.calculate(
        account: source,
        transactions: sourceTransactions,
      ),
    );
    expect(collections['transactions'], hasLength(7));
    expect(await AppSettingsService.loadCurrencyCode(), 'JPY');
  });

  test('replaces populated snapshot and repeating is idempotent', () async {
    final repository = BackupRepository(isar);
    final initial = _plan(2000);
    final replacement = _plan(3000);
    expect((await repository.restoreVersion2Backup(initial)).succeeded, isTrue);

    final firstResult = await repository.restoreVersion2Backup(replacement);
    expect(firstResult.succeeded, isTrue);
    final expected = _collectionsFrom(await snapshot());
    expect(
      (expected['accounts'] as List).map((item) => (item as Map)['id']).toSet(),
      {_uuid(3001), _uuid(3002)},
    );

    final secondResult = await repository.restoreVersion2Backup(replacement);
    expect(secondResult.succeeded, isTrue);
    await expectCollections(expected);
    expect(await isar.transactionModels.count(), 7);
  });

  test('valid empty collections replace all existing records', () async {
    final repository = BackupRepository(isar);
    expect(
      (await repository.restoreVersion2Backup(_plan(4000))).succeeded,
      isTrue,
    );

    final emptyPlan = _plan(5000, populated: false);
    final result = await repository.restoreVersion2Backup(emptyPlan);

    expect(result.succeeded, isTrue);
    expect(result.restoredCounts.values, everyElement(0));
    expect(_collectionsFrom(await snapshot()).values, everyElement(isEmpty));
    await DatabaseInitializer.seedDatabase(isar);
    expect(await isar.accountModels.count(), 0);
    expect(await isar.categoryModels.count(), 0);
    expect(await AppSettingsService.hasCompletedFullSnapshotRestore(), isTrue);
    expect(await AppSettingsService.loadCurrencyCode(), 'JPY');
  });

  test(
    'invalid plans and V1 inputs fail without mutating existing data',
    () async {
      final repository = BackupRepository(isar);
      expect(
        (await repository.restoreVersion2Backup(_plan(6000))).succeeded,
        isTrue,
      );

      final invalidPlan = _plan(7000);
      final exposedAccounts = invalidPlan.accounts;
      exposedAccounts[1].uuid = exposedAccounts[0].uuid;
      expect(invalidPlan.accounts[1].uuid, _uuid(7002));
      final restoredOriginalPlan = await repository.restoreVersion2Backup(
        invalidPlan,
      );
      expect(restoredOriginalPlan.succeeded, isTrue);
      final before = _collectionsFrom(await snapshot());

      final nullResult = await repository.restoreVersion2Backup(null);
      expect(nullResult.succeeded, isFalse);
      await expectCollections(before);

      expect(
        () => repository.preflightVersion2Backup(
          jsonEncode({
            'format': 'finance-tracker-backup',
            'schemaVersion': 2,
            'metadata': {'exportedAt': '2026-01-01T00:00:00.000Z'},
            'manifest': {},
            'collections': {'accounts': []},
          }),
        ),
        throwsFormatException,
      );
      await expectCollections(before);
    },
  );

  test(
    'failure after account insertion rolls back all six collections',
    () async {
      final seedRepository = BackupRepository(isar);
      expect(
        (await seedRepository.restoreVersion2Backup(_plan(8000))).succeeded,
        isTrue,
      );
      final before = _collectionsFrom(await snapshot());

      final failingRepository = BackupRepository(
        isar,
        restoreTransactionHook: () async {
          throw StateError('synthetic failure after account insertion');
        },
      );
      final result = await failingRepository.restoreVersion2Backup(_plan(9000));

      expect(result.succeeded, isFalse);
      expect(result.errorMessage, contains('Existing data was left unchanged'));
      await expectCollections(before);
      expect(await isar.accountModels.count(), 2);
      expect(await isar.categoryModels.count(), 2);
      expect(await isar.transactionModels.count(), 7);
      expect(await isar.recurringTransactionModels.count(), 1);
      expect(await isar.financialGoalModels.count(), 1);
      expect(await isar.investmentModels.count(), 1);
    },
  );
}
