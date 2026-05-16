import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';

import '../../shared/models/account_model.dart';
import '../../shared/models/category_model.dart';
import '../../shared/models/credit_card_model.dart';
import '../../shared/models/loan_model.dart';
import '../../shared/models/transaction_model.dart';

class IsarService {
  static Future<Isar> openIsar() async {
    final dir = await getApplicationDocumentsDirectory();

    return await Isar.open(
      [
        TransactionModelSchema,
        CategoryModelSchema,
        AccountModelSchema,
        LoanModelSchema,
        CreditCardModelSchema,
      ],
      inspector: true,
      directory: dir.path,
    );
  }
}