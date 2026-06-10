import 'package:finance_tracker/shared/models/recurring_transaction_model.dart';
import 'package:isar_community/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../shared/models/account_model.dart';
import '../../shared/models/category_model.dart';
import '../../shared/models/transaction_model.dart';
import '../../shared/models/investment_model.dart';

class IsarService {

  static Isar? _isar;

  static String? _currentDatabaseName;

  static Future<Isar> openIsar() async {

    final user =
        Supabase.instance.client.auth.currentUser;

    final databaseName =
        user == null

            ? 'finance_tracker_guest'

            : 'finance_tracker_${user.id}';

    // Reuse current database
    if (
      _isar != null &&
      _currentDatabaseName ==
          databaseName
    ) {

      return _isar!;
    }

    // User changed -> close old database
    // if (
    //   _isar != null &&
    //   _currentDatabaseName !=
    //       databaseName
    // ) {

    //   await _isar!.close();

    //   _isar = null;

    //   _currentDatabaseName =
    //       null;
    // }

    // Reuse already-open instance
    final existingInstance =
        Isar.getInstance(
      databaseName,
    );

    if (existingInstance !=
        null) {

      _isar =
          existingInstance;

      _currentDatabaseName =
          databaseName;

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
      ],

      name: databaseName,

      inspector: true,

      directory: dir.path,
    );

    _currentDatabaseName =
        databaseName;

    return _isar!;
  }

  static Future<void>
      closeCurrentDatabase()
  async {

    if (_isar != null) {

      await _isar!.close();

      _isar = null;

      _currentDatabaseName =
          null;
    }
  }
}