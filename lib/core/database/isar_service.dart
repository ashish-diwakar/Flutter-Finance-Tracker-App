import 'package:finance_tracker/shared/models/recurring_transaction_model.dart';
import 'package:isar_community/isar.dart';
import 'package:path_provider/path_provider.dart';

import '../../shared/models/account_model.dart';
import '../../shared/models/category_model.dart';
import '../../shared/models/financial_goal_model.dart';
import '../../shared/models/investment_model.dart';
import '../../shared/models/transaction_model.dart';

class IsarService {

  static Isar? _isar;

  static const String _databaseName =
      'finance_tracker';

  static Future<Isar> openIsar() async {

    // Reuse already opened instance
    if (_isar != null) {
      return _isar!;
    }

    // Check if an instance is already open
    final existingInstance =
        Isar.getInstance(
      _databaseName,
    );

    if (existingInstance != null) {

      _isar = existingInstance;

      return _isar!;
    }

    final dir =
        await getApplicationDocumentsDirectory();

    _isar = await Isar.open(

      [

        TransactionModelSchema,

        CategoryModelSchema,

        AccountModelSchema,

        RecurringTransactionModelSchema,

        InvestmentModelSchema,

        FinancialGoalModelSchema,
      ],

      name: _databaseName,

      directory: dir.path,

      inspector: true,
    );

    return _isar!;
  }

  static Future<void> closeDatabase() async {

    if (_isar != null) {

      await _isar!.close();

      _isar = null;
    }
  }
}