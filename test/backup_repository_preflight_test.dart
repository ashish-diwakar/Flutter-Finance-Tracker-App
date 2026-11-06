import 'dart:convert';
import 'dart:ffi';
import 'dart:io';

import 'package:finance_tracker/features/backup/data/repositories/backup_repository.dart';
import 'package:finance_tracker/shared/models/account_model.dart';
import 'package:finance_tracker/shared/models/category_model.dart';
import 'package:finance_tracker/shared/models/financial_goal_model.dart';
import 'package:finance_tracker/shared/models/investment_model.dart';
import 'package:finance_tracker/shared/models/recurring_transaction_model.dart';
import 'package:finance_tracker/shared/models/transaction_model.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:isar_community/isar.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
    directory = await Directory.systemTemp.createTemp('finance_backup_');
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
      name: 'backup_preflight_test',
      inspector: false,
    );
  });

  tearDown(() async {
    await isar.close(deleteFromDisk: true);
    await directory.delete(recursive: true);
  });

  Future<(AccountModel, CategoryModel, TransactionModel)>
  seedExistingData() async {
    final account = AccountModel()
      ..uuid = 'existing-account'
      ..name = 'Existing account'
      ..type = 'cash'
      ..currentBalance = 12345;
    final category = CategoryModel()
      ..uuid = 'existing-category'
      ..name = 'Existing category'
      ..type = 'expense';
    final transaction = TransactionModel()
      ..uuid = 'existing-transaction'
      ..amount = 2500
      ..type = 'expense'
      ..accountId = account.uuid
      ..categoryId = category.uuid
      ..transactionDate = DateTime(2026, 11, 6);

    await isar.writeTxn(() async {
      await isar.accountModels.put(account);
      await isar.categoryModels.put(category);
      await isar.transactionModels.put(transaction);
    });

    return (account, category, transaction);
  }

  Future<void> expectExistingData(
    (AccountModel, CategoryModel, TransactionModel) existing,
  ) async {
    final accounts = await isar.accountModels.where().findAll();
    final categories = await isar.categoryModels.where().findAll();
    final transactions = await isar.transactionModels.where().findAll();

    expect(accounts.map((item) => item.uuid), [existing.$1.uuid]);
    expect(accounts.single.name, existing.$1.name);
    expect(categories.map((item) => item.uuid), [existing.$2.uuid]);
    expect(categories.single.name, existing.$2.name);
    expect(transactions.map((item) => item.uuid), [existing.$3.uuid]);
    expect(transactions.single.amount, existing.$3.amount);
  }

  test(
    'invalid JSON preflight leaves existing collections unchanged',
    () async {
      final existing = await seedExistingData();
      final file = File('${directory.path}/invalid.json');
      await file.writeAsString('{invalid json');

      await expectLater(
        BackupRepository(
          isar,
        ).prepareBackupImportFile(file, fileName: 'invalid.json'),
        throwsA(isA<FormatException>()),
      );

      await expectExistingData(existing);
    },
  );

  test(
    'missing backup IDs are rejected before existing data is changed',
    () async {
      final existing = await seedExistingData();
      final file = File('${directory.path}/missing_id.json');
      await file.writeAsString(
        jsonEncode({
          'accounts': [],
          'categories': [{}],
          'transactions': [],
        }),
      );

      await expectLater(
        BackupRepository(
          isar,
        ).prepareBackupImportFile(file, fileName: 'missing_id.json'),
        throwsA(isA<Exception>()),
      );

      await expectExistingData(existing);
    },
  );

  test('valid preflight is non-destructive until restore is called', () async {
    final existing = await seedExistingData();
    final file = File('${directory.path}/valid.json');
    await file.writeAsString(
      jsonEncode({
        'accounts': [
          {
            'id': 'backup-account',
            'name': 'Restored account',
            'type': 'cash',
            'currentBalance': 9000,
          },
        ],
        'categories': [],
        'transactions': [
          {
            'id': 'backup-transaction',
            'amount': 1000,
            'type': 'income',
            'accountId': 'backup-account',
            'transactionDate': '2026-11-01T00:00:00.000Z',
          },
        ],
      }),
    );

    final repository = BackupRepository(isar);
    final prepared = await repository.prepareBackupImportFile(
      file,
      fileName: 'valid.json',
    );

    expect(prepared.fileName, 'valid.json');
    await expectExistingData(existing);

    await repository.restoreBackup(prepared);

    final restoredAccounts = await isar.accountModels.where().findAll();
    final restoredTransactions = await isar.transactionModels.where().findAll();
    expect(restoredAccounts, hasLength(1));
    expect(restoredAccounts.single.name, 'Restored account');
    expect(restoredTransactions, hasLength(1));
    expect(restoredTransactions.single.amount, 1000);
    expect(await isar.categoryModels.where().findAll(), isEmpty);
  });

  test('failed restore transaction rolls back collection clears', () async {
    final existing = await seedExistingData();
    final malformedCategory = CategoryModel()..uuid = 'malformed-category';
    final prepared = PreparedBackupImport(
      fileName: 'malformed.json',
      transactions: [],
      categories: [malformedCategory],
      accounts: [],
    );

    await expectLater(
      BackupRepository(isar).restoreBackup(prepared),
      throwsA(anything),
    );

    await expectExistingData(existing);
  });

  test(
    'version 2 backup is rejected before the legacy importer changes data',
    () async {
      final existing = await seedExistingData();
      final file = File('${directory.path}/version_2.json');
      await file.writeAsString(
        jsonEncode({
          'format': 'finance-tracker-backup',
          'schemaVersion': 2,
          'collections': {
            'accounts': [],
            'categories': [],
            'transactions': [],
            'recurringTransactions': [],
            'financialGoals': [],
            'investments': [],
          },
        }),
      );

      await expectLater(
        BackupRepository(
          isar,
        ).prepareBackupImportFile(file, fileName: 'version_2.json'),
        throwsA(
          isA<FormatException>().having(
            (error) => error.message,
            'message',
            contains('not supported for import yet'),
          ),
        ),
      );

      await expectExistingData(existing);
    },
  );

  test('version 2 export contains all portable records and metadata', () async {
    SharedPreferences.setMockInitialValues({'selected_currency': 'JPY'});

    final account = AccountModel()
      ..uuid = 'account-stable-uuid'
      ..name = 'Archived cash'
      ..type = 'cash'
      ..currentBalance = 9007199254740991
      ..isArchived = true
      ..isDefault = true
      ..createdAt = DateTime.utc(2026, 1, 2)
      ..updatedAt = DateTime.utc(2026, 2, 3)
      ..isDeleted = true;
    final category = CategoryModel()
      ..uuid = 'category-stable-uuid'
      ..name = 'Portable category'
      ..type = 'expense'
      ..icon = 'shopping_bag'
      ..colorValue = 0xff123456
      ..isDefault = true
      ..createdAt = DateTime.utc(2026, 3, 4)
      ..updatedAt = DateTime.utc(2026, 4, 5)
      ..monthlyBudget = 12875
      ..isDeleted = true;
    final transfer = TransactionModel()
      ..uuid = 'transaction-stable-uuid'
      ..amount = 9007199254740991
      ..type = 'transfer'
      ..accountId = account.uuid
      ..toAccountId = 'destination-account-uuid'
      ..categoryId = category.uuid
      ..relatedTransactionId = 'parent-transaction-uuid'
      ..counterpartyName = 'Counterparty'
      ..dueDate = DateTime.utc(2026, 12, 1)
      ..notes = 'Transfer note'
      ..transactionDate = DateTime.utc(2026, 11, 6, 12, 30)
      ..createdAt = DateTime.utc(2026, 5, 6)
      ..updatedAt = DateTime.utc(2026, 6, 7)
      ..isDeleted = true;
    final recurring = RecurringTransactionModel()
      ..uuid = 'recurring-stable-uuid'
      ..amount = 1337
      ..type = 'expense'
      ..categoryId = category.uuid
      ..accountId = account.uuid
      ..notes = 'Monthly'
      ..startDate = DateTime.utc(2026, 1, 1)
      ..endDate = DateTime.utc(2027, 1, 1)
      ..frequency = 'monthly'
      ..interval = 2
      ..isActive = true
      ..nextRunDate = DateTime.utc(2026, 11, 1)
      ..updatedAt = DateTime.utc(2026, 10, 1)
      ..isDeleted = true;
    final goal = FinancialGoalModel()
      ..uuid = 'goal-stable-uuid'
      ..name = 'Emergency fund'
      ..description = 'Keep the goal description'
      ..targetAmount = 1000000
      ..currentAmount = 125500
      ..linkedAccountId = account.uuid
      ..targetDate = DateTime.utc(2027, 12, 31)
      ..createdAt = DateTime.utc(2026, 1, 1)
      ..updatedAt = DateTime.utc(2026, 10, 1)
      ..isCompleted = false
      ..isDeleted = true;
    final investment = InvestmentModel()
      ..uuid = 'investment-stable-uuid'
      ..name = 'Fixed deposit'
      ..type = 'fixed'
      ..symbol = 'FD-1'
      ..notes = 'Investment note'
      ..quantity = 3
      ..purchasePrice = 1234567890123
      ..currentPrice = 1234567890456
      ..purchaseDate = DateTime.utc(2026, 1, 15)
      ..createdAt = DateTime.utc(2026, 1, 15)
      ..updatedAt = DateTime.utc(2026, 10, 1)
      ..interestRate = 7.123456789012345
      ..maturityDate = DateTime.utc(2029, 1, 15)
      ..maturityValue = 1500000000000
      ..investmentClass = 'fixed_income'
      ..isDeleted = true;

    await isar.writeTxn(() async {
      await isar.accountModels.put(account);
      await isar.categoryModels.put(category);
      await isar.transactionModels.put(transfer);
      await isar.recurringTransactionModels.put(recurring);
      await isar.financialGoalModels.put(goal);
      await isar.investmentModels.put(investment);
    });

    final json =
        jsonDecode(await BackupRepository(isar).generateBackupJson())
            as Map<String, dynamic>;
    final collections = json['collections'] as Map<String, dynamic>;
    final manifest = json['manifest'] as Map<String, dynamic>;
    final metadata = json['metadata'] as Map<String, dynamic>;
    final exportedAccount =
        (collections['accounts'] as List).single as Map<String, dynamic>;
    final exportedCategory =
        (collections['categories'] as List).single as Map<String, dynamic>;
    final exportedTransaction =
        (collections['transactions'] as List).single as Map<String, dynamic>;
    final exportedRecurring =
        (collections['recurringTransactions'] as List).single
            as Map<String, dynamic>;
    final exportedGoal =
        (collections['financialGoals'] as List).single as Map<String, dynamic>;
    final exportedInvestment =
        (collections['investments'] as List).single as Map<String, dynamic>;

    expect(json['format'], 'finance-tracker-backup');
    expect(json['schemaVersion'], 2);
    expect(DateTime.parse(metadata['exportedAt'] as String).isUtc, isTrue);
    expect(metadata['appVersion'], isNull);
    expect(metadata['currencyCode'], 'JPY');
    expect(manifest.values, everyElement({'recordCount': 1}));

    expect(exportedAccount['id'], account.uuid);
    expect(exportedAccount['currentBalance'], account.currentBalance);
    expect(exportedAccount['isArchived'], isTrue);
    expect(exportedAccount['isDeleted'], isTrue);
    expect(exportedAccount['isDefault'], isTrue);
    expect(exportedAccount['createdAt'], '2026-01-02T00:00:00.000Z');
    expect(exportedAccount['updatedAt'], '2026-02-03T00:00:00.000Z');
    expect(exportedAccount.containsKey('isSynced'), isFalse);
    expect(exportedAccount['id'], isNot(account.id));
    expect(exportedAccount.keys, {
      'id',
      'name',
      'type',
      'currentBalance',
      'isArchived',
      'isDefault',
      'createdAt',
      'updatedAt',
      'isDeleted',
    });

    expect(exportedCategory['id'], category.uuid);
    expect(exportedCategory['icon'], category.icon);
    expect(exportedCategory['colorValue'], category.colorValue);
    expect(exportedCategory['monthlyBudget'], category.monthlyBudget);
    expect(exportedCategory['isDefault'], isTrue);
    expect(exportedCategory['isDeleted'], isTrue);
    expect(exportedCategory['createdAt'], '2026-03-04T00:00:00.000Z');
    expect(exportedCategory['updatedAt'], '2026-04-05T00:00:00.000Z');
    expect(exportedCategory.keys, {
      'id',
      'name',
      'type',
      'icon',
      'colorValue',
      'isDefault',
      'createdAt',
      'updatedAt',
      'isDeleted',
      'monthlyBudget',
    });

    expect(exportedTransaction['id'], transfer.uuid);
    expect(exportedTransaction['amount'], transfer.amount);
    expect(exportedTransaction['accountId'], account.uuid);
    expect(exportedTransaction['categoryId'], category.uuid);
    expect(exportedTransaction['toAccountId'], transfer.toAccountId);
    expect(
      exportedTransaction['relatedTransactionId'],
      transfer.relatedTransactionId,
    );
    expect(exportedTransaction['counterpartyName'], transfer.counterpartyName);
    expect(exportedTransaction['dueDate'], '2026-12-01T00:00:00.000Z');
    expect(exportedTransaction['notes'], transfer.notes);
    expect(exportedTransaction['transactionDate'], '2026-11-06T12:30:00.000Z');
    expect(exportedTransaction['createdAt'], '2026-05-06T00:00:00.000Z');
    expect(exportedTransaction['updatedAt'], '2026-06-07T00:00:00.000Z');
    expect(exportedTransaction['isDeleted'], isTrue);
    expect(exportedTransaction.containsKey('isSynced'), isFalse);
    expect(exportedTransaction.keys, {
      'id',
      'amount',
      'type',
      'categoryId',
      'accountId',
      'toAccountId',
      'counterpartyName',
      'relatedTransactionId',
      'dueDate',
      'notes',
      'transactionDate',
      'createdAt',
      'updatedAt',
      'isDeleted',
    });

    expect(exportedRecurring['id'], recurring.uuid);
    expect(exportedRecurring['amount'], recurring.amount);
    expect(exportedRecurring['type'], recurring.type);
    expect(exportedRecurring['categoryId'], recurring.categoryId);
    expect(exportedRecurring['accountId'], recurring.accountId);
    expect(exportedRecurring['notes'], recurring.notes);
    expect(exportedRecurring['startDate'], '2026-01-01T00:00:00.000Z');
    expect(exportedRecurring['endDate'], '2027-01-01T00:00:00.000Z');
    expect(exportedRecurring['frequency'], recurring.frequency);
    expect(exportedRecurring['interval'], recurring.interval);
    expect(exportedRecurring['nextRunDate'], '2026-11-01T00:00:00.000Z');
    expect(exportedRecurring['updatedAt'], '2026-10-01T00:00:00.000Z');
    expect(exportedRecurring['isActive'], isTrue);
    expect(exportedRecurring['isDeleted'], isTrue);
    expect(exportedRecurring.containsKey('isSynced'), isFalse);
    expect(exportedRecurring.keys, {
      'id',
      'amount',
      'type',
      'categoryId',
      'accountId',
      'notes',
      'startDate',
      'endDate',
      'frequency',
      'interval',
      'isActive',
      'nextRunDate',
      'updatedAt',
      'isDeleted',
    });

    expect(exportedGoal['id'], goal.uuid);
    expect(exportedGoal['targetAmount'], goal.targetAmount);
    expect(exportedGoal['currentAmount'], goal.currentAmount);
    expect(exportedGoal['name'], goal.name);
    expect(exportedGoal['description'], goal.description);
    expect(exportedGoal['linkedAccountId'], account.uuid);
    expect(exportedGoal['targetDate'], '2027-12-31T00:00:00.000Z');
    expect(exportedGoal['createdAt'], '2026-01-01T00:00:00.000Z');
    expect(exportedGoal['updatedAt'], '2026-10-01T00:00:00.000Z');
    expect(exportedGoal['isCompleted'], isFalse);
    expect(exportedGoal['isDeleted'], isTrue);
    expect(exportedGoal.containsKey('isSynced'), isFalse);
    expect(exportedGoal.keys, {
      'id',
      'name',
      'description',
      'targetAmount',
      'currentAmount',
      'linkedAccountId',
      'targetDate',
      'createdAt',
      'updatedAt',
      'isCompleted',
      'isDeleted',
    });

    expect(exportedInvestment['id'], investment.uuid);
    expect(exportedInvestment['name'], investment.name);
    expect(exportedInvestment['type'], investment.type);
    expect(exportedInvestment['symbol'], investment.symbol);
    expect(exportedInvestment['notes'], investment.notes);
    expect(exportedInvestment['quantity'], investment.quantity);
    expect(exportedInvestment['purchasePrice'], investment.purchasePrice);
    expect(exportedInvestment['currentPrice'], investment.currentPrice);
    expect(exportedInvestment['purchaseDate'], '2026-01-15T00:00:00.000Z');
    expect(exportedInvestment['createdAt'], '2026-01-15T00:00:00.000Z');
    expect(exportedInvestment['updatedAt'], '2026-10-01T00:00:00.000Z');
    expect(exportedInvestment['interestRate'], investment.interestRate);
    expect(exportedInvestment['maturityDate'], '2029-01-15T00:00:00.000Z');
    expect(exportedInvestment['maturityValue'], investment.maturityValue);
    expect(exportedInvestment['investmentClass'], investment.investmentClass);
    expect(exportedInvestment['isDeleted'], isTrue);
    expect(exportedInvestment.containsKey('isSynced'), isFalse);
    expect(exportedInvestment.keys, {
      'id',
      'name',
      'type',
      'symbol',
      'notes',
      'quantity',
      'purchasePrice',
      'currentPrice',
      'purchaseDate',
      'createdAt',
      'updatedAt',
      'interestRate',
      'maturityDate',
      'maturityValue',
      'investmentClass',
      'isDeleted',
    });
  });

  test(
    'version 2 export represents empty collections and zero counts',
    () async {
      SharedPreferences.setMockInitialValues({});

      final json =
          jsonDecode(await BackupRepository(isar).generateBackupJson())
              as Map<String, dynamic>;
      final collections = json['collections'] as Map<String, dynamic>;
      final manifest = json['manifest'] as Map<String, dynamic>;

      expect(collections.keys, {
        'accounts',
        'categories',
        'transactions',
        'recurringTransactions',
        'financialGoals',
        'investments',
      });
      expect(collections.values, everyElement(isEmpty));
      expect(manifest.values, everyElement({'recordCount': 0}));
      expect((json['metadata'] as Map)['currencyCode'], isNull);
    },
  );
}
