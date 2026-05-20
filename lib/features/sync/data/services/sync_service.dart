import 'package:finance_tracker/main.dart';
import 'package:isar/isar.dart';

import '../../../../core/services/supabase_service.dart';
import '../../../../shared/models/account_model.dart';
import '../../../../shared/models/category_model.dart';
import '../../../../shared/models/transaction_model.dart';
import '../../../../core/services/logger_service.dart';

class SyncService {

  final Isar isar;

  SyncService(this.isar);

  final client =
      SupabaseService.client;

  Future<void> syncAll() async {

    logger.d('--------------------------------------------------------------------');
    logger.d('--------------------------------------------------------------------');
    logger.d('Starting full sync for user: ${client.auth.currentUser?.id}');
    logger.d('--------------------------------------------------------------------');
    logger.d('--------------------------------------------------------------------');

    final sessionReady = await ensureValidSession();

    if (!sessionReady) {

      logger.e(
        'Aborting sync: no valid Supabase session. User must sign in again.',
      );

      throw StateError(
        'No valid Supabase session. Please sign in again.',
      );
    }

    await executeSafely(
      syncCategories,
    );

    await executeSafely(
      syncAccounts,
    );

    await executeSafely(
      syncTransactions,
    );

    await executeSafely(
      pullTransactions,
    );
  }

  Future<void> syncCategories() async {

    final user =
        client.auth.currentUser;

    logger.d('Starting category sync for user: ${user?.id}');

    if (user == null) {
      logger.e('User is null');
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

        'is_deleted':
            category.isDeleted,

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

        'is_default':
            account.isDefault,

        'is_deleted':
            account.isDeleted,

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

      final cloudDeleted =
          (item['is_deleted'] as bool?) ??
              false;

      if (existing == null) {

        if (cloudDeleted) {
          continue;
        }

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
              ..isSynced = true
              ..isDeleted = cloudDeleted;

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

          existing.isDeleted = cloudDeleted;

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

        'is_deleted':
            transaction.isDeleted,

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


  Future<void> executeSafely(
    Future<void> Function() action,
  ) async {

    try {

      await action();

    } catch (e) {

      LoggerService.error(
        e.toString(),
      );
    }
  }

  Future<bool> ensureValidSession() async {

    final user = client.auth.currentUser;

    if (user == null) {

      logger.e('ensureValidSession: no currentUser');

      return false;
    }

    final session = client.auth.currentSession;

    if (session == null) {

      logger.e(
        'ensureValidSession: currentUser present but session is null',
      );

      return false;
    }

    if (!session.isExpired) {
      return true;
    }

    logger.d(
      'ensureValidSession: session expired, attempting refresh',
    );

    try {

      final response =
          await client.auth.refreshSession();

      return response.session != null &&
          !response.session!.isExpired;

    } catch (e) {

      logger.e(
        'ensureValidSession: refresh failed: $e',
      );

      return false;
    }
  }

}