import 'dart:convert';
import 'dart:ffi';
import 'dart:io';

import 'package:finance_tracker/features/backup/data/repositories/backup_repository.dart';
import 'package:finance_tracker/shared/models/account_model.dart';
import 'package:finance_tracker/shared/models/category_model.dart';
import 'package:finance_tracker/shared/models/transaction_model.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:isar_community/isar.dart';

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
      [AccountModelSchema, CategoryModelSchema, TransactionModelSchema],
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
}
