import 'package:isar/isar.dart';

import '../../../../shared/models/transaction_model.dart';

class TransactionRepository {
  final Isar isar;

  TransactionRepository(this.isar);

  Future<void> addTransaction(TransactionModel transaction) async {
    await isar.writeTxn(() async {
      await isar.transactionModels.put(transaction);
    });
  }

  Future<List<TransactionModel>> getTransactions() async {
    return await isar.transactionModels.where().findAll();
  }

  Future<void> deleteTransaction(Id id) async {
    await isar.writeTxn(() async {
      await isar.transactionModels.delete(id);
    });
  }
}