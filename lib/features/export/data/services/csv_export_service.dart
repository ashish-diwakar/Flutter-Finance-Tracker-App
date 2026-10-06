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
    final categories =
        await isar.categoryModels
            .where()
            .findAll();

    final accounts =
        await isar.accountModels
            .where()
            .findAll();

    final categoryMap = <String, String>{
      for (final category in categories)
        category.uuid: category.name,
    };

    final accountMap = <String, String>{
      for (final account in accounts)
        account.uuid: account.name,
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
      final categoryId =
          transaction.categoryId;

      final categoryName =
          categoryId == null ||
                  categoryId.isEmpty
              ? ''
              : categoryMap[categoryId] ??
                  'Unknown Category';

      final accountName =
          accountMap[transaction.accountId] ??
              'Unknown Account';

      final toAccountId =
          transaction.toAccountId;

      final toAccountName =
          toAccountId == null ||
                  toAccountId.isEmpty
              ? ''
              : accountMap[toAccountId] ??
                  'Unknown Account';

      rows.add([
        transaction.transactionDate
            .toIso8601String(),
        _typeLabel(transaction.type),
        transaction.amount / 100,
        categoryName,
        accountName,
        toAccountName,
        transaction.counterpartyName ?? '',
        transaction.relatedTransactionId ?? '',
        transaction.dueDate
                ?.toIso8601String() ??
            '',
        transaction.notes ?? '',
      ]);
    }

    final csv =
        const ListToCsvConverter()
            .convert(rows);

    final dir =
        await getTemporaryDirectory();

    final file = File(
      '${dir.path}/transactions.csv',
    );

    await file.writeAsString(csv);

    return file;
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
