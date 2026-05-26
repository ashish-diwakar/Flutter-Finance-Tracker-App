import 'package:isar/isar.dart';

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
    Id id,
  ) async {

    final model =
        await isar
            .recurringTransactionModels
            .get(id);

    if (model == null) {
      return;
    }

    model.isDeleted = true;

    model.updatedAt =
        DateTime.now();

    model.isSynced = false;

    await isar.writeTxn(() async {

      await isar
          .recurringTransactionModels
          .put(model);
    });
  }
}