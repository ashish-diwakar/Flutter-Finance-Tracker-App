import 'package:isar/isar.dart';

import '../../../../core/services/supabase_service.dart';
import '../../../../shared/models/account_model.dart';
import '../../../../shared/models/category_model.dart';
import '../../../../shared/models/transaction_model.dart';

class SyncService {

  final Isar isar;

  SyncService(this.isar);

  final client =
      SupabaseService.client;

  Future<void> syncAll() async {

    await syncCategories();

    await syncAccounts();

    await syncTransactions();

    await pullTransactions();
  }

  Future<void> syncCategories() async {

    final user =
        client.auth.currentUser;

    if (user == null) {
      return;
    }

    final unsynced =
        await isar.categoryModels
            .filter()
            .isSyncedEqualTo(false)
            .findAll();

    for (final category in unsynced) {

      await client
          .from('categories')
          .upsert({

        'id': category.id,

        'user_id': user.id,

        'name': category.name,

        'type': category.type,

        'is_default':
            category.isDefault,

        'updated_at':
            DateTime.now()
                .toIso8601String(),
      });

      category.isSynced = true;

      category.updatedAt =
          DateTime.now();

      await isar.writeTxn(() async {

        await isar.categoryModels
            .put(category);
      });
    }
  }

  Future<void> syncAccounts() async {

    final user =
        client.auth.currentUser;

    if (user == null) {
      return;
    }

    final unsynced =
        await isar.accountModels
            .filter()
            .isSyncedEqualTo(false)
            .findAll();

    for (final account in unsynced) {

      await client
          .from('accounts')
          .upsert({

        'id': account.id,

        'user_id': user.id,

        'name': account.name,

        'type': account.type,

        'current_balance':
            account.currentBalance,

        'updated_at':
            DateTime.now()
                .toIso8601String(),
      });

      account.isSynced = true;

      account.updatedAt =
          DateTime.now();

      await isar.writeTxn(() async {

        await isar.accountModels
            .put(account);
      });
    }
  }

  Future<void> pullTransactions()
      async {

    final user =
        client.auth.currentUser;

    if (user == null) {
      return;
    }

    final response =
        await client
            .from('transactions')
            .select()
            .eq('user_id', user.id);

    for (final item in response) {

      final existing =
          await isar.transactionModels
              .get(item['id']);

      final cloudUpdated =
          DateTime.parse(
        item['updated_at'],
      );

      if (existing == null) {

        final transaction =
            TransactionModel()

              ..id = item['id']
              ..amount =
                  item['amount']
              ..type =
                  item['type']
              ..categoryId =
                  item['category_id']
              ..accountId =
                  item['account_id']
              ..notes =
                  item['notes']
              ..transactionDate =
                  DateTime.parse(
                item['transaction_date'],
              )
              ..updatedAt =
                  cloudUpdated
              ..isSynced = true;

        await isar.writeTxn(() async {

          await isar.transactionModels
              .put(transaction);
        });

      } else {

        final localUpdated =
            existing.updatedAt ??
                DateTime(2000);

        if (cloudUpdated
            .isAfter(localUpdated)) {

          existing.amount =
              item['amount'];

          existing.type =
              item['type'];

          existing.categoryId =
              item['category_id'];

          existing.accountId =
              item['account_id'];

          existing.notes =
              item['notes'];

          existing.transactionDate =
              DateTime.parse(
            item['transaction_date'],
          );

          existing.updatedAt =
              cloudUpdated;

          existing.isSynced = true;

          await isar.writeTxn(() async {

            await isar.transactionModels
                .put(existing);
          });
        }
      }
    }
  }
  Future<void> syncTransactions()
      async {

    final user =
        client.auth.currentUser;

    if (user == null) {
      return;
    }

    final unsynced =
        await isar.transactionModels
            .filter()
            .isSyncedEqualTo(false)
            .findAll();

    for (final transaction
        in unsynced) {

      await client
          .from('transactions')
          .upsert({

        'id': transaction.id,

        'user_id': user.id,

        'amount':
            transaction.amount,

        'type': transaction.type,

        'category_id':
            transaction.categoryId,

        'account_id':
            transaction.accountId,

        'notes':
            transaction.notes,

        'transaction_date':
            transaction
                .transactionDate
                .toIso8601String(),

        'updated_at':
            DateTime.now()
                .toIso8601String(),
      });

      transaction.isSynced = true;

      transaction.updatedAt =
          DateTime.now();

      await isar.writeTxn(() async {

        await isar.transactionModels
            .put(transaction);
      });
    }
  }
}