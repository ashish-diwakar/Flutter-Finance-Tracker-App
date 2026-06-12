import 'package:isar_community/isar.dart';

import '../../../shared/models/recurring_transaction_model.dart';

class RecurringRepository {

  final Isar isar;

  RecurringRepository(
    this.isar,
  );

  Future<void> addRecurring(
    RecurringTransactionModel model,
  ) async {

    await isar.writeTxn(() async {

      await isar
          .recurringTransactionModels
          .put(model);
    });
  }

  Future<List<
      RecurringTransactionModel>>
      getAllRecurring() async {

    return await isar
        .recurringTransactionModels
        .filter()
        .isDeletedEqualTo(false)
        .findAll();
  }

  Future<void> updateRecurring(
    RecurringTransactionModel model,
  ) async {

    await isar.writeTxn(() async {

      await isar
          .recurringTransactionModels
          .put(model);
    });
  }

  Future<void> deleteRecurring(
    RecurringTransactionModel model,
  ) async {

    model.isDeleted = true;

    model.updatedAt =
        DateTime.now().toUtc();

    model.isSynced = false;

    await isar.writeTxn(() async {

      await isar
          .recurringTransactionModels
          .put(model);
    });
  }
}