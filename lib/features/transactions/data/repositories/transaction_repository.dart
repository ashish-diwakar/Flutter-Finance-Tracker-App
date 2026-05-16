import 'package:isar/isar.dart';

import '../../../../shared/models/transaction_model.dart';

class TransactionRepository {
  final Isar isar;

  TransactionRepository(this.isar);

  Future<void> addTransaction(
    TransactionModel transaction,
  ) async {
    await isar.writeTxn(() async {
      await isar.transactionModels.put(transaction);
    });
  }

  Future<void> deleteTransaction(Id id) async {
    await isar.writeTxn(() async {
      await isar.transactionModels.delete(id);
    });
  }

  Stream<List<TransactionModel>> watchTransactions() {
    return isar.transactionModels
        .where()
        .watch(fireImmediately: true);
  }

  Future<List<TransactionModel>> getTransactions() async {
    return await isar.transactionModels
        .where()
        .sortByTransactionDateDesc()
        .findAll();
  }

  Future<int> getTotalIncome() async {
    final transactions = await isar.transactionModels
        .filter()
        .typeEqualTo('income')
        .findAll();

    return transactions.fold<int>(
      0,
      (int sum, item) => sum + item.amount,
    );
  }

  Future<int> getTotalExpense() async {
    final transactions = await isar.transactionModels
        .filter()
        .typeEqualTo('expense')
        .findAll();

    return transactions.fold<int>(
      0,
      (int sum, item) => sum + item.amount,
    );
  }
}