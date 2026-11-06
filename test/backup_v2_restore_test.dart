import 'dart:convert';
import 'dart:ffi';
import 'dart:io';
import 'package:finance_tracker/core/database/full_snapshot_restore_marker.dart';
import 'dart:typed_data';

import 'package:finance_tracker/core/database/database_initializer.dart';
import 'package:finance_tracker/core/services/app_settings_service.dart';
import 'package:finance_tracker/features/accounts/domain/services/account_balance_service.dart';
import 'package:finance_tracker/features/backup/data/repositories/backup_repository.dart';
import 'package:finance_tracker/features/backup/domain/services/backup_v2_preflight.dart';
import 'package:finance_tracker/features/recurring/data/recurring_repository.dart';
import 'package:finance_tracker/shared/models/account_model.dart';
import 'package:finance_tracker/shared/models/category_model.dart';
import 'package:finance_tracker/shared/models/financial_goal_model.dart';
import 'package:finance_tracker/shared/models/investment_model.dart';
import 'package:finance_tracker/shared/models/recurring_transaction_model.dart';
import 'package:finance_tracker/shared/models/transaction_model.dart';
import 'package:file_picker/file_picker.dart';
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

  Future<Isar> openDatabase({bool includeMarker = true}) {
    return Isar.open(
      [
        AccountModelSchema,
        CategoryModelSchema,
        TransactionModelSchema,
        RecurringTransactionModelSchema,
        FinancialGoalModelSchema,
        InvestmentModelSchema,
        if (includeMarker) FullSnapshotRestoreMarkerSchema,
      ],
      directory: directory.path,
      name: 'v2_restore_test',
      inspector: false,
    );
  }

  setUp(() async {
    SharedPreferences.setMockInitialValues({'selected_currency': 'JPY'});
    directory = await Directory.systemTemp.createTemp('finance_v2_restore_');
    isar = await openDatabase();
  });

  tearDown(() async {
    await isar.close(deleteFromDisk: true);
    await directory.delete(recursive: true);
  });

  Future<String> snapshot() => BackupRepository(isar).generateBackupJson();

  Future<void> expectCollections(Map<String, dynamic> expected) async {
    expect(_collectionsFrom(await snapshot()), equals(expected));
  }

  test(
    'export and import preflight preserve a deleted zero-target goal',
    () async {
      final goal = FinancialGoalModel()
        ..uuid = _uuid(41)
        ..name = 'Synthetic historical goal'
        ..description = 'Synthetic description'
        ..targetAmount = 0
        ..currentAmount = 0
        ..targetDate = DateTime.utc(2026, 4, 1)
        ..createdAt = DateTime.utc(2026, 1, 1)
        ..updatedAt = DateTime.utc(2026, 3, 1)
        ..isCompleted = true
        ..isDeleted = true
        ..isSynced = true;
      await isar.writeTxn(() => isar.financialGoalModels.put(goal));
      final before = _collectionsFrom(await snapshot());
      Uint8List? savedBytes;
      final repository = BackupRepository(
        isar,
        localFileSaver: ({required fileName, required bytes}) async {
          expect(fileName, matches(r'^finance_backup_\d{8}_\d{6}\.json$'));
          savedBytes = bytes;
          return 'synthetic destination';
        },
        backupImportFilePicker: () async => PlatformFile(
          name: 'synthetic.json',
          size: savedBytes!.length,
          bytes: savedBytes,
        ),
      );

      expect(await repository.saveBackupLocally(), isTrue);
      expect(_collectionsFrom(utf8.decode(savedBytes!)), before);
      final prepared = await repository.prepareVersion2BackupImport();
      expect(
        prepared!.plan.financialGoals.single.toBackupJson(),
        goal.toBackupJson(),
      );
      await expectCollections(before);
      final stored = await isar.financialGoalModels.get(goal.id);
      expect(stored!.toBackupJson(), goal.toBackupJson());
      expect(stored.isSynced, isTrue);
      expect(await isar.fullSnapshotRestoreMarkers.count(), 0);
    },
  );

  test('restores all six collections into an empty database', () async {
    final plan = _plan(1000);
    final result = await BackupRepository(isar).restoreVersion2Backup(plan);

    expect(result.succeeded, isTrue);
    expect(result.errorMessage, isNull);
    expect(result.warnings, isEmpty);
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

  test(
    'file preparation preflights V2 input without database writes',
    () async {
      final before = _collectionsFrom(await snapshot());
      final bytes = Uint8List.fromList(
        utf8.encode(jsonEncode(_document(base: 1200))),
      );
      final repository = BackupRepository(
        isar,
        backupImportFilePicker: () async => PlatformFile(
          name: 'synthetic.json',
          size: bytes.length,
          bytes: bytes,
        ),
      );

      final prepared = await repository.prepareVersion2BackupImport();

      expect(prepared, isNotNull);
      expect(prepared!.fileName, 'synthetic.json');
      expect(prepared.plan.recordCounts, {
        'accounts': 2,
        'categories': 2,
        'transactions': 7,
        'recurringTransactions': 1,
        'financialGoals': 1,
        'investments': 1,
      });
      expect(prepared.plan.totalRecordCount, 14);
      await expectCollections(before);
    },
  );

  test(
    'file preparation rejects malformed, partial, unsupported, and V1 files',
    () async {
      final before = _collectionsFrom(await snapshot());
      final cancelledRepository = BackupRepository(
        isar,
        backupImportFilePicker: () async => null,
      );
      expect(await cancelledRepository.prepareVersion2BackupImport(), isNull);
      await expectCollections(before);

      final partial = _document(base: 1200);
      (partial['collections'] as Map).remove('investments');
      final unsupported = _document(base: 1200)..['schemaVersion'] = 999;
      for (final content in [
        '{',
        jsonEncode(partial),
        jsonEncode(unsupported),
        jsonEncode({'transactions': [], 'categories': [], 'accounts': []}),
      ]) {
        final bytes = Uint8List.fromList(utf8.encode(content));
        final repository = BackupRepository(
          isar,
          backupImportFilePicker: () async => PlatformFile(
            name: 'invalid.json',
            size: bytes.length,
            bytes: bytes,
          ),
        );
        await expectLater(
          repository.prepareVersion2BackupImport(),
          throwsFormatException,
        );
        await expectCollections(before);
      }
    },
  );

  test(
    'preflight reports every dangling schedule reference without writes',
    () async {
      final account = AccountModel()
        ..uuid = _uuid(42)
        ..name = 'Existing synthetic account'
        ..type = 'cash'
        ..currentBalance = 123;
      await isar.writeTxn(() => isar.accountModels.put(account));
      final before = _collectionsFrom(await snapshot());
      final document = _document(base: 1200, populated: false);
      final template =
          ((_document(base: 1200)['collections']
                          as Map)['recurringTransactions']
                      as List)
                  .single
              as Map<String, dynamic>;
      (document['collections'] as Map)['recurringTransactions'] = [
        {
          ...template,
          'id': _uuid(50),
          'accountId': _uuid(51),
          'categoryId': _uuid(52),
        },
        {
          ...template,
          'id': _uuid(60),
          'accountId': _uuid(61),
          'categoryId': _uuid(62),
          'isDeleted': true,
        },
      ];
      (document['manifest'] as Map)['recurringTransactions'] = {
        'recordCount': 2,
      };
      final bytes = Uint8List.fromList(utf8.encode(jsonEncode(document)));
      final repository = BackupRepository(
        isar,
        backupImportFilePicker: () async => PlatformFile(
          name: 'synthetic.json',
          size: bytes.length,
          bytes: bytes,
        ),
      );
      await expectLater(
        repository.prepareVersion2BackupImport(),
        throwsA(
          isA<MissingRecurringReferencesException>()
              .having(
                (error) => error.message,
                'message',
                'Recurring schedules reference accounts or categories missing from the backup.',
              )
              .having((error) => error.paths, 'paths', [
                r'$.collections.recurringTransactions[0].accountId',
                r'$.collections.recurringTransactions[0].categoryId',
                r'$.collections.recurringTransactions[1].accountId',
                r'$.collections.recurringTransactions[1].categoryId',
              ]),
        ),
      );
      await expectCollections(before);
      expect(await isar.fullSnapshotRestoreMarkers.count(), 0);
    },
  );

  test(
    'manual relink preserves schedule state and makes a fresh V2 export valid',
    () async {
      final account = AccountModel()
        ..uuid = _uuid(70)
        ..name = 'Synthetic archived account'
        ..type = 'cash'
        ..currentBalance = 1234
        ..isArchived = true;
      final category = CategoryModel()
        ..uuid = _uuid(71)
        ..name = 'Synthetic expense category'
        ..type = 'expense';
      final wrongType = CategoryModel()
        ..uuid = _uuid(72)
        ..name = 'Synthetic income category'
        ..type = 'income';
      final schedule = RecurringTransactionModel()
        ..uuid = _uuid(80)
        ..accountId = _uuid(81)
        ..categoryId = _uuid(82)
        ..type = 'expense'
        ..amount = 9007199254740993
        ..notes = '  Preserve synthetic notes verbatim  '
        ..startDate = DateTime.utc(2024, 2, 1, 11)
        ..endDate = DateTime.utc(2030, 3, 1, 17)
        ..frequency = 'monthly'
        ..interval = 3
        ..nextRunDate = DateTime.utc(2024, 5, 1, 11)
        ..updatedAt = DateTime.utc(2024, 4, 1)
        ..isActive = true
        ..isSynced = true;
      await isar.writeTxn(() async {
        await isar.accountModels.put(account);
        await isar.categoryModels.putAll([category, wrongType]);
        await isar.recurringTransactionModels.put(schedule);
      });
      final originalBackup = await snapshot();
      expect(
        () => BackupV2Preflight.parse(originalBackup),
        throwsFormatException,
      );
      String? savedJson;
      final exporter = BackupRepository(
        isar,
        localFileSaver: ({required fileName, required bytes}) async {
          savedJson = utf8.decode(bytes);
          return 'synthetic destination';
        },
      );
      expect(
        await exporter.saveBackupLocally(confirmUnverified: (_) async => false),
        isFalse,
      );
      expect(savedJson, isNull);
      await expectCollections(_collectionsFrom(originalBackup));
      final original = (await isar.recurringTransactionModels.get(
        schedule.id,
      ))!;
      final repository = RecurringRepository(isar);
      Future<void> relink({String? accountId, String? categoryId}) =>
          repository.relinkRecurring(
            original,
            accountId: accountId ?? account.uuid,
            categoryId: categoryId ?? category.uuid,
          );

      await expectLater(
        relink(categoryId: wrongType.uuid),
        throwsA(isA<RecurringRelinkException>()),
      );
      await expectLater(
        relink(accountId: _uuid(999)),
        throwsA(isA<RecurringRelinkException>()),
      );
      account.isDeleted = true;
      await isar.writeTxn(() => isar.accountModels.put(account));
      await expectLater(relink(), throwsA(isA<RecurringRelinkException>()));
      account.isDeleted = false;
      category.isDeleted = true;
      await isar.writeTxn(() async {
        await isar.accountModels.put(account);
        await isar.categoryModels.put(category);
      });
      await expectLater(relink(), throwsA(isA<RecurringRelinkException>()));
      category.isDeleted = false;
      await isar.writeTxn(() => isar.categoryModels.put(category));
      expect(
        (await isar.recurringTransactionModels.get(
          schedule.id,
        ))!.toBackupJson(),
        original.toBackupJson(),
      );

      await relink();
      final updated = (await isar.recurringTransactionModels.get(schedule.id))!;
      expect(updated.toBackupJson(), {
        ...original.toBackupJson(),
        'accountId': account.uuid,
        'categoryId': category.uuid,
        'updatedAt': updated.toBackupJson()['updatedAt'],
      });
      expect(updated.updatedAt.isAfter(original.updatedAt), isTrue);
      expect(updated.isSynced, original.isSynced);
      expect(await isar.recurringTransactionModels.count(), 1);
      expect(await isar.transactionModels.count(), 0);
      expect((await isar.accountModels.get(account.id))!.currentBalance, 1234);
      expect(
        BackupV2Preflight.parse(
          await snapshot(),
        ).recurringTransactions.single.uuid,
        schedule.uuid,
      );
      expect(await exporter.saveBackupLocally(), isTrue);
      expect(
        BackupV2Preflight.parse(
          savedJson!,
        ).recurringTransactions.single.accountId,
        account.uuid,
      );
      expect(
        () => BackupV2Preflight.parse(originalBackup),
        throwsFormatException,
      );
    },
  );

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
    await isar.close();
    SharedPreferences.setMockInitialValues({'selected_currency': 'JPY'});
    isar = await openDatabase();
    await DatabaseInitializer.seedDatabase(isar);
    expect(await isar.accountModels.count(), 0);
    expect(await isar.categoryModels.count(), 0);
    expect(await isar.fullSnapshotRestoreMarkers.count(), 1);
    expect(await AppSettingsService.loadCurrencyCode(), 'JPY');
  });

  test('startup still honors the legacy preference marker', () async {
    SharedPreferences.setMockInitialValues({
      'completed_full_snapshot_restore': true,
    });
    await DatabaseInitializer.seedDatabase(isar);
    expect(await isar.accountModels.count(), 0);
    expect(await isar.categoryModels.count(), 0);
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
      expect(
        result.errorMessage,
        contains('Existing financial records were left unchanged'),
      );
      await expectCollections(before);
      expect(await isar.accountModels.count(), 2);
      expect(await isar.categoryModels.count(), 2);
      expect(await isar.transactionModels.count(), 7);
      expect(await isar.recurringTransactionModels.count(), 1);
      expect(await isar.financialGoalModels.count(), 1);
      expect(await isar.investmentModels.count(), 1);
      await DatabaseInitializer.seedDatabase(isar);
      await expectCollections(before);
    },
  );

  test('marker write failure prevents database mutation', () async {
    // Omitting the schema makes the real marker write fail after all six
    // collections have been replaced inside the transaction.
    await isar.close();
    isar = await openDatabase(includeMarker: false);
    final existingAccount = AccountModel()
      ..uuid = _uuid(7501)
      ..name = 'Pre-existing synthetic account'
      ..type = 'cash'
      ..currentBalance = 4567;
    await isar.writeTxn(() => isar.accountModels.put(existingAccount));
    final before = _collectionsFrom(await snapshot());

    final repository = BackupRepository(isar);
    final result = await repository.restoreVersion2Backup(_plan(7600));

    expect(result.succeeded, isFalse);
    expect(
      result.errorMessage,
      contains('Existing financial records were left unchanged'),
    );
    await expectCollections(before);
    expect(await isar.accountModels.count(), 1);
    await isar.close();
    isar = await openDatabase();
    expect(await isar.fullSnapshotRestoreMarkers.count(), 0);
    await DatabaseInitializer.seedDatabase(isar);
    expect(await isar.accountModels.count(), 1);
    expect(await isar.categoryModels.count(), greaterThan(0));
    expect(await AppSettingsService.loadCurrencyCode(), 'JPY');
  });
}
