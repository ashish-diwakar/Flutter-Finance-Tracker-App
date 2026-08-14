import 'dart:io';

import 'package:csv/csv.dart';
import 'package:isar_community/isar.dart';
import 'package:path_provider/path_provider.dart';

import '../../../../shared/models/account_model.dart';
import '../../../../shared/models/category_model.dart';
import '../../../../shared/models/transaction_model.dart';

class CsvExportService {
  final Isar isar;

  CsvExportService(this.isar);

  Future<File> exportTransactions(
    List<TransactionModel> transactions,
  ) async {

    // ==========================================
    // Load Categories
    // ==========================================

    final categories =
        await isar.categoryModels
            .filter()
            .isDeletedEqualTo(false)
            .findAll();

    // ==========================================
    // Load Accounts
    // ==========================================

    final accounts =
        await isar.accountModels
            .filter()
            .isDeletedEqualTo(false)
            .findAll();

    // ==========================================
    // Create Lookup Maps
    // ==========================================

    final categoryMap = <String, String>{
      for (final category in categories)
        category.uuid: category.name,
    };

    final accountMap = <String, String>{
      for (final account in accounts)
        account.uuid: account.name,
    };

    // ==========================================
    // CSV Rows
    // ==========================================

    final List<List<dynamic>> rows = [];

    rows.add([
      'Date',
      'Type',
      'Amount',
      'Category',
      'Account',
      'Notes',
    ]);

    // ==========================================
    // Transactions
    // ==========================================

    for (final transaction in transactions) {

      final categoryName =
          categoryMap[transaction.categoryId] ??
              'Unknown Category';

      final accountName =
          accountMap[transaction.accountId] ??
              'Unknown Account';

      rows.add([
        transaction.transactionDate.toIso8601String(),
        transaction.type,
        transaction.amount / 100,
        categoryName,
        accountName,
        transaction.notes ?? '',
      ]);
    }

    // ==========================================
    // Generate CSV
    // ==========================================

    final csv =
        const ListToCsvConverter().convert(rows);

    final dir =
        await getTemporaryDirectory();

    final file = File(
      '${dir.path}/transactions.csv',
    );

    await file.writeAsString(csv);

    return file;
  }
}