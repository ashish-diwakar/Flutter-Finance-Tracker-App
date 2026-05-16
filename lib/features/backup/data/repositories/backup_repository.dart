import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../../../shared/models/account_model.dart';
import '../../../../shared/models/category_model.dart';
import '../../../../shared/models/transaction_model.dart';
import '../../domain/models/backup_data_model.dart';

class BackupRepository {

  final Isar isar;

  BackupRepository(this.isar);

  Future<File> exportBackup() async {

    final transactions =
        await isar.transactionModels
            .where()
            .findAll();

    final categories =
        await isar.categoryModels
            .where()
            .findAll();

    final accounts =
        await isar.accountModels
            .where()
            .findAll();

    final backup =
        BackupDataModel(
      transactions:
          transactions
              .map((e) => e.toJson())
              .toList(),

      categories:
          categories
              .map((e) => e.toJson())
              .toList(),

      accounts:
          accounts
              .map((e) => e.toJson())
              .toList(),
    );

    final jsonString =
        jsonEncode(
      backup.toJson(),
    );

    final directory =
        await getApplicationDocumentsDirectory();

    final file = File(
      '${directory.path}/finance_backup.json',
    );

    await file.writeAsString(
      jsonString,
    );

    return file;
  }

  Future<void> shareBackup() async {

    final file =
        await exportBackup();

    await Share.shareXFiles([
      XFile(file.path),
    ]);
  }

  Future<void> importBackup() async {

    final result =
        await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['json'],
    );

    if (result == null) {
      return;
    }

    final path =
        result.files.single.path;

    if (path == null) {
      return;
    }

    final file = File(path);

    final content =
        await file.readAsString();

    final json =
        jsonDecode(content);

    final backup =
        BackupDataModel.fromJson(json);

    await isar.writeTxn(() async {

      await isar.transactionModels
          .clear();

      await isar.categoryModels.clear();

      await isar.accountModels.clear();

      final transactions =
          backup.transactions
              .map(
                (e) =>
                    TransactionModel()
                      ..id = e['id']
                      ..amount =
                          e['amount']
                      ..type =
                          e['type']
                      ..categoryId =
                          e['categoryId']
                      ..accountId =
                          e['accountId']
                      ..notes =
                          e['notes']
                      ..transactionDate =
                          DateTime.parse(
                        e['transactionDate'],
                      ),
              )
              .toList();

      final categories =
          backup.categories
              .map(
                (e) =>
                    CategoryModel()
                      ..id = e['id']
                      ..name =
                          e['name']
                      ..type =
                          e['type']
                      ..isDefault =
                          e['isDefault'],
              )
              .toList();

      final accounts =
          backup.accounts
              .map(
                (e) =>
                    AccountModel()
                      ..id = e['id']
                      ..name =
                          e['name']
                      ..type =
                          e['type']
                      ..currentBalance =
                          e['currentBalance'],
              )
              .toList();

      await isar.transactionModels
          .putAll(transactions);

      await isar.categoryModels
          .putAll(categories);

      await isar.accountModels
          .putAll(accounts);
    });
  }
}