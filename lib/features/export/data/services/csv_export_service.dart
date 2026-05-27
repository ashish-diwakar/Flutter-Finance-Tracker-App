import 'dart:io';

import 'package:csv/csv.dart';
import 'package:path_provider/path_provider.dart';

import '../../../../shared/models/transaction_model.dart';

class CsvExportService {

  Future<File>
      exportTransactions(

    List<TransactionModel>
        transactions,
  ) async {

    final List<List<dynamic>>
        rows = [];

    rows.add([

      'Date',

      'Type',

      'Amount',

      'Category ID',

      'Account ID',

      'Notes',
    ]);

    for (final transaction
        in transactions) {

      rows.add([

        transaction.transactionDate
            .toIso8601String(),

        transaction.type,

        transaction.amount / 100,

        transaction.categoryId,

        transaction.accountId,

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

    await file.writeAsString(
      csv,
    );

    return file;
  }
}