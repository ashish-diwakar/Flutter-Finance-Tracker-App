import 'package:isar_community/isar.dart';
import '../../../../shared/models/category_model.dart';
import '../../../../shared/models/recurring_transaction_model.dart';
import '../../../../shared/models/transaction_model.dart';
import '../../../../shared/models/account_model.dart';
import '../../../../shared/models/investment_model.dart';


class LocalDataCleaner {

  static Future<void> clearAll(
    Isar isar,
  ) async {

    await isar.writeTxn(() async {

      await isar.transactionModels.clear();

      await isar.categoryModels.clear();

      await isar.accountModels.clear();

      await isar.recurringTransactionModels.clear();

      await isar.investmentModels.clear();

    });
  }
}