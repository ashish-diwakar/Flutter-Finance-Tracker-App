import 'dart:io';

import 'package:csv/csv.dart';
import 'package:isar_community/isar.dart';
import 'export_temporary_files.dart';

import '../../../../shared/models/account_model.dart';
import '../../../../shared/models/category_model.dart';
import '../../../../shared/models/transaction_model.dart';

class CsvExportService {
  final Isar isar;

  CsvExportService(this.isar, {ExportTemporaryFiles? temporaryFiles})
    : _temporaryFiles = temporaryFiles ?? ExportTemporaryFiles();

  final ExportTemporaryFiles _temporaryFiles;

  Future<File> exportTransactions(List<TransactionModel> transactions) async {
    final categories = await isar.categoryModels.where().findAll();

    final accounts = await isar.accountModels.where().findAll();

    final categoryMap = <String, String>{
      for (final category in categories) category.uuid: category.name,
    };

    final accountMap = <String, String>{
      for (final account in accounts) account.uuid: account.name,
    };

    final List<List<dynamic>> rows = [];

    rows.add([
      'Date',
      'Type',
      'Amount',
      'Category',
      'Account',
      'To Account',
      'Counterparty',
      'Related Transaction ID',
      'Due Date',
      'Notes',
    ]);

    for (final transaction in transactions) {
      final categoryId = transaction.categoryId;

      final categoryName = categoryId == null || categoryId.isEmpty
          ? ''
          : categoryMap[categoryId] ?? 'Unknown Category';

      final accountName =
          accountMap[transaction.accountId] ?? 'Unknown Account';

      final toAccountId = transaction.toAccountId;

      final toAccountName = toAccountId == null || toAccountId.isEmpty
          ? ''
          : accountMap[toAccountId] ?? 'Unknown Account';

      rows.add([
        transaction.transactionDate.toIso8601String(),
        _typeLabel(transaction.type),
        transaction.amount / 100,
        categoryName,
        accountName,
        toAccountName,
        transaction.counterpartyName ?? '',
        transaction.relatedTransactionId ?? '',
        transaction.dueDate?.toIso8601String() ?? '',
        transaction.notes ?? '',
      ]);
    }

    final csv = const ListToCsvConverter().convert(rows);

    final file = await _temporaryFiles.createSource('transactions.csv');
    try {
      await file.writeAsString(csv);
      return file;
    } catch (_) {
      await _temporaryFiles.cleanSource(file);
      rethrow;
    }
  }

  String _typeLabel(String type) {
    switch (type) {
      case 'income':
        return 'Income';
      case 'expense':
        return 'Expense';
      case 'transfer':
        return 'Transfer';
      case 'borrowed':
        return 'Borrowed';
      case 'lent':
        return 'Lent';
      case 'repaymentPaid':
        return 'Repayment Paid';
      case 'repaymentReceived':
        return 'Repayment Received';
      default:
        return type;
    }
  }
}
