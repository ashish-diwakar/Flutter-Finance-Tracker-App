import 'package:isar_community/isar.dart';

import '../../../shared/models/account_model.dart';
import '../../../shared/models/category_model.dart';
import '../../../shared/models/recurring_transaction_model.dart';

class RecurringRelinkException implements Exception {
  final String message;

  const RecurringRelinkException(this.message);
}

class RecurringRepository {
  final Isar isar;

  RecurringRepository(this.isar);

  Future<void> addRecurring(RecurringTransactionModel model) async {
    await isar.writeTxn(() async {
      await isar.recurringTransactionModels.put(model);
    });
  }

  Future<List<RecurringTransactionModel>> getAllRecurring() async {
    return await isar.recurringTransactionModels
        .filter()
        .isDeletedEqualTo(false)
        .findAll();
  }

  Future<void> updateRecurring(RecurringTransactionModel model) async {
    await isar.writeTxn(() async {
      await isar.recurringTransactionModels.put(model);
    });
  }

  Future<void> relinkRecurring(
    RecurringTransactionModel original, {
    required String accountId,
    required String categoryId,
  }) async {
    await isar.writeTxn(() async {
      final schedule = await isar.recurringTransactionModels.get(original.id);
      if (schedule == null ||
          schedule.isDeleted ||
          schedule.uuid != original.uuid ||
          schedule.type != original.type ||
          schedule.accountId != original.accountId ||
          schedule.categoryId != original.categoryId) {
        throw const RecurringRelinkException(
          'This schedule changed. Reopen it before repairing its references.',
        );
      }

      final account = await isar.accountModels.getByUuid(accountId);
      if (account == null || account.isDeleted) {
        throw const RecurringRelinkException(
          'The selected account is no longer available. Choose another account.',
        );
      }
      final category = await isar.categoryModels.getByUuid(categoryId);
      if (category == null ||
          category.isDeleted ||
          category.type != schedule.type) {
        throw const RecurringRelinkException(
          'The selected category is no longer available for this schedule type. Choose another category.',
        );
      }

      schedule
        ..accountId = accountId
        ..categoryId = categoryId
        ..updatedAt = DateTime.now().toUtc();
      await isar.recurringTransactionModels.put(schedule);
    });
  }

  Future<void> deleteRecurring(RecurringTransactionModel model) async {
    model.isDeleted = true;

    model.updatedAt = DateTime.now().toUtc();

    model.isSynced = false;

    await isar.writeTxn(() async {
      await isar.recurringTransactionModels.put(model);
    });
  }
}
