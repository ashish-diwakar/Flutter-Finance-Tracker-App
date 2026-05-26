import 'package:finance_tracker/shared/models/recurring_transaction_model.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';

import '../../shared/models/account_model.dart';
import '../../shared/models/category_model.dart';
import '../../shared/models/credit_card_model.dart';
import '../../shared/models/loan_model.dart';
import '../../shared/models/transaction_model.dart';

class IsarService {

  static Isar? _isar;

  static Future<Isar> openIsar()
  async {

    if (_isar != null) {

      return _isar!;
    }

    if (Isar.instanceNames
        .isNotEmpty) {

      _isar =
          Isar.getInstance();

      return _isar!;
    }

    final dir =
        await getApplicationDocumentsDirectory();

    _isar = await Isar.open(

      [

        TransactionModelSchema,

        CategoryModelSchema,

        AccountModelSchema,

        LoanModelSchema,

        CreditCardModelSchema,

        RecurringTransactionModelSchema,
      ],

      inspector: true,

      directory: dir.path,
    );

    return _isar!;
  }
}