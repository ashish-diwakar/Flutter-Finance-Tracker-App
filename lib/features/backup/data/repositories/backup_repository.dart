import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:finance_tracker/core/services/app_settings_service.dart';
import 'package:finance_tracker/core/services/logger_service.dart';
import 'package:intl/intl.dart';
import 'package:isar_community/isar.dart';
import 'package:share_plus/share_plus.dart';
import 'package:uuid/uuid.dart';

import '../../../../shared/models/account_model.dart';
import '../../../../shared/models/category_model.dart';
import '../../../../shared/models/financial_goal_model.dart';
import '../../../../shared/models/investment_model.dart';
import '../../../../shared/models/recurring_transaction_model.dart';
import '../../../../shared/models/transaction_model.dart';
import '../../domain/models/backup_data_model.dart';
import '../../domain/services/backup_v2_preflight.dart';

typedef BackupLocalFileSaver =
    Future<String?> Function({
      required String fileName,
      required Uint8List bytes,
    });

typedef BackupFileSharer = Future<void> Function(File file);
typedef BackupRestoreTransactionHook = Future<void> Function();

class BackupRepository {
  final Isar isar;
  final BackupLocalFileSaver _localFileSaver;
  final BackupFileSharer _fileSharer;
  final BackupRestoreTransactionHook? _restoreTransactionHook;

  BackupRepository(
    this.isar, {
    BackupLocalFileSaver? localFileSaver,
    BackupFileSharer? fileSharer,
    BackupRestoreTransactionHook? restoreTransactionHook,
  }) : _localFileSaver = localFileSaver ?? _saveWithFilePicker,
       _fileSharer = fileSharer ?? _shareWithPlugin,
       _restoreTransactionHook = restoreTransactionHook;

  Future<String> generateBackupJson() async {
    final currencyCode = await AppSettingsService.loadCurrencyCode();
    final snapshot = await isar.txn(
      () async => (
        transactions: await isar.transactionModels.where().findAll(),
        categories: await isar.categoryModels.where().findAll(),
        accounts: await isar.accountModels.where().findAll(),
        recurringTransactions: await isar.recurringTransactionModels
            .where()
            .findAll(),
        financialGoals: await isar.financialGoalModels.where().findAll(),
        investments: await isar.investmentModels.where().findAll(),
      ),
    );

    final backup = BackupDataModel(
      exportedAt: DateTime.now().toUtc(),
      appVersion: null,
      currencyCode: currencyCode,
      transactions: snapshot.transactions.map((e) => e.toBackupJson()).toList(),
      categories: snapshot.categories.map((e) => e.toBackupJson()).toList(),
      accounts: snapshot.accounts.map((e) => e.toBackupJson()).toList(),
      recurringTransactions: snapshot.recurringTransactions
          .map((e) => e.toBackupJson())
          .toList(),
      financialGoals: snapshot.financialGoals
          .map((e) => e.toBackupJson())
          .toList(),
      investments: snapshot.investments.map((e) => e.toBackupJson()).toList(),
    );

    return jsonEncode(backup.toJson());
  }

  ValidatedBackupRestorePlan preflightVersion2Backup(String content) {
    return BackupV2Preflight.parse(content);
  }

  Future<BackupRestoreResult> restoreVersion2Backup(
    ValidatedBackupRestorePlan? plan,
  ) async {
    if (plan == null) {
      return BackupRestoreResult.failure(
        'No validated V2 backup was provided.',
      );
    }

    late final ValidatedBackupRestorePlan snapshot;
    try {
      snapshot = BackupV2Preflight.parse(jsonEncode(plan.toBackupJson()));
    } on Object {
      return BackupRestoreResult.failure(
        'The validated backup plan is invalid or has been modified.',
      );
    }

    final accounts = snapshot.accounts
      ..forEach((item) {
        item.id = Isar.autoIncrement;
        // Sync state is device-local and is not part of portable V2 data.
        item.isSynced = false;
      });
    final categories = snapshot.categories
      ..forEach((item) {
        item.id = Isar.autoIncrement;
        item.isSynced = false;
      });
    final transactions = snapshot.transactions
      ..forEach((item) {
        item.id = Isar.autoIncrement;
        item.isSynced = false;
      });
    final recurringTransactions = snapshot.recurringTransactions
      ..forEach((item) {
        item.id = Isar.autoIncrement;
        item.isSynced = false;
      });
    final financialGoals = snapshot.financialGoals
      ..forEach((item) {
        item.id = Isar.autoIncrement;
        item.isSynced = false;
      });
    final investments = snapshot.investments
      ..forEach((item) {
        item.id = Isar.autoIncrement;
        item.isSynced = false;
      });

    try {
      await isar.writeTxn(() async {
        await isar.accountModels.clear();
        await isar.categoryModels.clear();
        await isar.transactionModels.clear();
        await isar.recurringTransactionModels.clear();
        await isar.financialGoalModels.clear();
        await isar.investmentModels.clear();

        if (accounts.isNotEmpty) await isar.accountModels.putAll(accounts);
        await _restoreTransactionHook?.call();
        if (categories.isNotEmpty) await isar.categoryModels.putAll(categories);
        if (transactions.isNotEmpty) {
          await isar.transactionModels.putAll(transactions);
        }
        if (recurringTransactions.isNotEmpty) {
          await isar.recurringTransactionModels.putAll(recurringTransactions);
        }
        if (financialGoals.isNotEmpty) {
          await isar.financialGoalModels.putAll(financialGoals);
        }
        if (investments.isNotEmpty) {
          await isar.investmentModels.putAll(investments);
        }
      });
    } on Object catch (error) {
      LoggerService.error(
        'V2 backup restore failed (${error.runtimeType}); transaction rolled back.',
      );
      return BackupRestoreResult.failure(
        'The backup could not be restored. Existing data was left unchanged.',
      );
    }

    final warnings = <String>[
      'Provider caches and device-local borrow/lend reminders require post-commit reconciliation.',
    ];
    try {
      await AppSettingsService.markFullSnapshotRestored();
    } on Object catch (error) {
      LoggerService.error(
        'V2 restore committed, but default-data suppression could not be saved '
        '(${error.runtimeType}).',
      );
      warnings.add(
        'The restored snapshot was committed, but default-data seeding may resume after an app restart.',
      );
    }

    return BackupRestoreResult.success(
      {
        'accounts': accounts.length,
        'categories': categories.length,
        'transactions': transactions.length,
        'recurringTransactions': recurringTransactions.length,
        'financialGoals': financialGoals.length,
        'investments': investments.length,
      },
      warnings: warnings,
    );
  }

  Future<bool> saveBackupLocally() async {
    final jsonString = await generateBackupJson();
    final result = await _localFileSaver(
      fileName: _suggestedBackupFileName(),
      bytes: Uint8List.fromList(utf8.encode(jsonString)),
    );
    return result != null;
  }

  Future<void> shareBackup() async {
    final jsonString = await generateBackupJson();
    final temporaryDirectory = await Directory.systemTemp.createTemp(
      'finance_tracker_backup_',
    );
    final file = File(
      '${temporaryDirectory.path}/${_suggestedBackupFileName()}',
    );

    try {
      await file.writeAsBytes(utf8.encode(jsonString), flush: true);
      await _fileSharer(file);
    } finally {
      await temporaryDirectory.delete(recursive: true);
    }
  }

  static Future<String?> _saveWithFilePicker({
    required String fileName,
    required Uint8List bytes,
  }) {
    return FilePicker.platform.saveFile(
      dialogTitle: 'Save Backup',
      fileName: fileName,
      type: FileType.custom,
      allowedExtensions: const ['json'],
      bytes: bytes,
    );
  }

  static Future<void> _shareWithPlugin(File file) async {
    await Share.shareXFiles([XFile(file.path)]);
  }

  static String _suggestedBackupFileName() {
    final timestamp = DateFormat(
      'yyyyMMdd_HHmmss',
    ).format(DateTime.now().toUtc());
    return 'finance_backup_$timestamp.json';
  }

  Future<PreparedBackupImport?> prepareBackupImport() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
      );

      LoggerService.info(
        'Backup file picker returned: ${result?.files.single.name}',
      );

      if (result == null) {
        LoggerService.error('BackupRepository: User cancelled file picker');
        return null;
      }

      final path = result.files.single.path;

      if (path == null) {
        throw Exception('Selected file has no path.');
      }

      return await prepareBackupImportFile(
        File(path),
        fileName: result.files.single.name,
      );
    } catch (e, stack) {
      LoggerService.error('Backup Error: $e');
      LoggerService.error('Backup Error: $stack');
      rethrow;
    }
  }

  Future<PreparedBackupImport> prepareBackupImportFile(
    File file, {
    required String fileName,
  }) async {
    try {
      final content = await file.readAsString();
      final decoded = jsonDecode(content);

      if (decoded is! Map<String, dynamic>) {
        throw Exception('Invalid backup file format.');
      }

      if (decoded.containsKey('format') ||
          decoded.containsKey('schemaVersion') ||
          decoded.containsKey('collections')) {
        throw const FormatException(
          'Versioned backups are not supported for import yet. '
          'Import a legacy version 1 backup instead.',
        );
      }

      return _prepareBackup(
        LegacyBackupDataModel.fromJson(decoded),
        fileName: fileName,
      );
    } catch (e, stack) {
      LoggerService.error('Backup Error: $e');
      LoggerService.error('Backup Error: $stack');
      rethrow;
    }
  }

  PreparedBackupImport _prepareBackup(
    LegacyBackupDataModel backup, {
    required String fileName,
  }) {
    const uuid = Uuid();

    final Map<dynamic, String> categoryMap = {};
    final categories = backup.categories.map((e) {
      final oldId = e['id'];

      if (oldId == null) {
        throw Exception('Category ID missing in backup.');
      }

      final newUuid = uuid.v4();
      categoryMap[oldId] = newUuid;

      return CategoryModel()
        ..uuid = newUuid
        ..name = e['name']
        ..type = e['type']
        ..isDefault = e['isDefault'] ?? false
        ..monthlyBudget = e['monthlyBudget'] ?? 0
        ..createdAt = e['createdAt'] != null
            ? DateTime.parse(e['createdAt'])
            : DateTime.now().toUtc()
        ..updatedAt = e['updatedAt'] != null
            ? DateTime.parse(e['updatedAt'])
            : DateTime.now().toUtc()
        ..isDeleted = e['isDeleted'] ?? false
        ..isSynced = false;
    }).toList();

    final Map<dynamic, String> accountMap = {};
    final accounts = backup.accounts.map((e) {
      final oldId = e['id'];

      if (oldId == null) {
        throw Exception('Account ID missing in backup.');
      }

      final newUuid = uuid.v4();
      accountMap[oldId] = newUuid;

      return AccountModel()
        ..uuid = newUuid
        ..name = e['name']
        ..type = e['type']
        ..currentBalance = e['currentBalance'] ?? 0
        ..isDefault = e['isDefault'] ?? false
        ..createdAt = e['createdAt'] != null
            ? DateTime.parse(e['createdAt'])
            : DateTime.now().toUtc()
        ..updatedAt = e['updatedAt'] != null
            ? DateTime.parse(e['updatedAt'])
            : DateTime.now().toUtc()
        ..isDeleted = e['isDeleted'] ?? false
        ..isSynced = false;
    }).toList();

    final Map<dynamic, String> transactionMap = {};
    for (final transaction in backup.transactions) {
      final oldId = transaction['id'];

      if (oldId == null) {
        throw Exception('Transaction ID missing in backup.');
      }

      transactionMap[oldId] = uuid.v4();
    }

    final transactions = backup.transactions.map((e) {
      final oldId = e['id'];
      final rawCategoryId = e['categoryId'];
      final rawAccountId = e['accountId'];
      final rawToAccountId = e['toAccountId'];
      final rawRelatedTransactionId = e['relatedTransactionId'];

      if (rawAccountId == null) {
        throw Exception('Transaction account ID missing in backup.');
      }

      final mappedAccountId = accountMap[rawAccountId];
      if (mappedAccountId == null) {
        throw Exception('Unable to restore transaction account.');
      }

      String? mappedCategoryId;
      if (rawCategoryId != null && rawCategoryId.toString().trim().isNotEmpty) {
        mappedCategoryId = categoryMap[rawCategoryId];
        if (mappedCategoryId == null) {
          throw Exception('Unable to restore transaction category.');
        }
      }

      String? mappedToAccountId;
      if (rawToAccountId != null &&
          rawToAccountId.toString().trim().isNotEmpty) {
        mappedToAccountId = accountMap[rawToAccountId];
        if (mappedToAccountId == null) {
          throw Exception('Unable to restore transfer destination account.');
        }
      }

      String? mappedRelatedTransactionId;
      if (rawRelatedTransactionId != null &&
          rawRelatedTransactionId.toString().trim().isNotEmpty) {
        mappedRelatedTransactionId = transactionMap[rawRelatedTransactionId];
        if (mappedRelatedTransactionId == null) {
          throw Exception('Unable to restore related transaction.');
        }
      }

      return TransactionModel()
        ..uuid = transactionMap[oldId]!
        ..amount = e['amount']
        ..type = e['type']
        ..categoryId = mappedCategoryId
        ..accountId = mappedAccountId
        ..toAccountId = mappedToAccountId
        ..counterpartyName = e['counterpartyName']
        ..relatedTransactionId = mappedRelatedTransactionId
        ..dueDate = e['dueDate'] != null ? DateTime.parse(e['dueDate']) : null
        ..notes = e['notes']
        ..transactionDate = DateTime.parse(e['transactionDate'])
        ..createdAt = e['createdAt'] != null
            ? DateTime.parse(e['createdAt'])
            : DateTime.now().toUtc()
        ..updatedAt = e['updatedAt'] != null
            ? DateTime.parse(e['updatedAt'])
            : DateTime.now().toUtc()
        ..isDeleted = e['isDeleted'] ?? false
        ..isSynced = false;
    }).toList();

    return PreparedBackupImport(
      fileName: fileName,
      transactions: transactions,
      categories: categories,
      accounts: accounts,
    );
  }

  Future<void> restoreBackup(PreparedBackupImport prepared) async {
    try {
      await isar.writeTxn(() async {
        await isar.transactionModels.clear();
        await isar.categoryModels.clear();
        await isar.accountModels.clear();

        await isar.categoryModels.putAll(prepared.categories);
        await isar.accountModels.putAll(prepared.accounts);
        await isar.transactionModels.putAll(prepared.transactions);
      });
    } catch (e, stack) {
      LoggerService.error('Backup Error: $e');
      LoggerService.error('Backup Error: $stack');
      rethrow;
    }
  }
}

class PreparedBackupImport {
  final String fileName;
  final List<TransactionModel> transactions;
  final List<CategoryModel> categories;
  final List<AccountModel> accounts;

  PreparedBackupImport({
    required this.fileName,
    required List<TransactionModel> transactions,
    required List<CategoryModel> categories,
    required List<AccountModel> accounts,
  }) : transactions = List.unmodifiable(transactions),
       categories = List.unmodifiable(categories),
       accounts = List.unmodifiable(accounts);
}

class BackupRestoreResult {
  final bool succeeded;
  final Map<String, int> restoredCounts;
  final String? errorMessage;
  final List<String> warnings;

  BackupRestoreResult._({
    required this.succeeded,
    required Map<String, int> restoredCounts,
    required this.errorMessage,
    required List<String> warnings,
  }) : restoredCounts = Map.unmodifiable(restoredCounts),
       warnings = List.unmodifiable(warnings);

  factory BackupRestoreResult.success(
    Map<String, int> restoredCounts, {
    List<String> warnings = const [],
  }) =>
      BackupRestoreResult._(
        succeeded: true,
        restoredCounts: restoredCounts,
        errorMessage: null,
        warnings: warnings,
      );

  factory BackupRestoreResult.failure(String errorMessage) =>
      BackupRestoreResult._(
        succeeded: false,
        restoredCounts: const {},
        errorMessage: errorMessage,
        warnings: const [],
      );
}
