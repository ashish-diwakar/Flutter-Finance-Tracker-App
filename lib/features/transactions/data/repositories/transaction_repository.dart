import 'package:isar_community/isar.dart';

import '../../../../shared/models/transaction_model.dart';

class TransactionRepository {

  final Isar isar;

  TransactionRepository(this.isar);

  Future<void> addTransaction(
    TransactionModel transaction,
  ) async {

    await isar.writeTxn(() async {

      transaction.updatedAt =
          DateTime.now().toUtc();

      transaction.isSynced =
          false;
          
      await isar.transactionModels.put(
        transaction,
      );
    });
  }

  Future<void> updateTransaction(
    TransactionModel transaction,
  ) async {

    transaction.updatedAt = DateTime.now().toUtc();

    transaction.isSynced = false;

    await isar.writeTxn(() async {

      await isar.transactionModels.put(
        transaction,
      );
    });
  }

  // Future<void> deleteTransaction(Id id) async {

  //   await isar.writeTxn(() async {

  //     await isar.transactionModels.delete(id);
  //   });
  // }

  Future<void> deleteTransaction(
    TransactionModel transaction,
  ) async {

    transaction.isDeleted = true;

    transaction.isSynced = false;

    transaction.updatedAt =
        DateTime.now().toUtc();

    await isar.writeTxn(() async {
      await isar.transactionModels
          .put(transaction);
    });
  }

  Stream<List<TransactionModel>>
      watchTransactions() {

    return isar.transactionModels
        .filter()
        .isDeletedEqualTo(false)
        .sortByTransactionDateDesc()
        .watch(
          fireImmediately: true,
        );
  }

  // Future<List<TransactionModel>>
  //     getTransactions() async {

  //   return await isar.transactionModels
  //       .filter()
  //       .isDeletedEqualTo(false)
  //       .typeEqualTo('income')
  //       .sortByTransactionDateDesc()
  //       .findAll();
  // }

  Future<int> getTotalIncome() async {

    final transactions =
        await isar.transactionModels
            .filter()
            .isDeletedEqualTo(false)
            .typeEqualTo('income')
            .findAll();

    return transactions.fold<int>(
      0,
      (int sum, TransactionModel item) => (sum + item.amount),
    );
  }

  Future<int> getTotalExpense() async {

    final transactions =
        await isar.transactionModels
            .filter()
            .isDeletedEqualTo(false)
            .typeEqualTo('expense')
            .findAll();

    return transactions.fold<int>(
      0,
      (int sum, TransactionModel item) => (sum + item.amount),
    );
  }
}