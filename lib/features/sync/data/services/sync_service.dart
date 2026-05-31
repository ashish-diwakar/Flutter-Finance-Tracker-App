import 'package:finance_tracker/main.dart';
import 'package:isar/isar.dart';

import '../../../../core/services/logger_service.dart';
import '../../../../core/services/supabase_service.dart';
import '../../../../shared/models/account_model.dart';
import '../../../../shared/models/category_model.dart';
import '../../../../shared/models/transaction_model.dart';
import '../../../../shared/models/recurring_transaction_model.dart';
import '../../../../shared/models/investment_model.dart';

class SyncService {

  final Isar isar;

  SyncService(this.isar);

  final client =
      SupabaseService.client;

  Future<void> syncAll() async {

    logger.d(
      '--------------------------------------------------------------------',
    );

    logger.d(
      'Starting full sync for user: ${client.auth.currentUser?.id}',
    );

    logger.d(
      '--------------------------------------------------------------------',
    );

    final sessionReady =
        await ensureValidSession();

    if (!sessionReady) {

      logger.e(
        'Aborting sync: no valid Supabase session',
      );

      throw StateError(
        'No valid Supabase session',
      );
    }

    await executeSafely(
      syncCategories,
    );

    await executeSafely(
      pullCategories,
    );

    await executeSafely(
      syncAccounts,
    );

    await executeSafely(
      pullAccounts,
    );

    await executeSafely(
      syncRecurringTransactions,
    );

     await executeSafely(
      pullRecurringTransactions,
    );

    await executeSafely(
      syncTransactions,
    );

    await executeSafely(
      pullTransactions,
    );

    await executeSafely(
      syncInvestments,
    );
    await executeSafely(
      pullInvestments,
    );

    await client
        .from('sync_metadata')
        .upsert({
      'user_id':
          client.auth.currentUser!.id,
      'last_sync_at':
          DateTime.now()
              .toIso8601String(),
      'last_device':
          'Android',
    });

  }

  // =========================================================
  // CATEGORY SYNC
  // =========================================================

  Future<void> syncCategories()
  async {

    final user =
        client.auth.currentUser;

    logger.d(
      'Starting category sync',
    );

    if (user == null) {
      return;
    }

    final unsynced =
        await isar.categoryModels
            .filter()
            .isSyncedEqualTo(false)
            .findAll();

    for (final category
        in unsynced) {
    logger.d(
      '----------------------------------------------------------------------------------------------', 
    );
    logger.d(
      'category to sync ${category.name}, ${category.type}, ${category.isDefault}, ${category.monthlyBudget},', 
    );


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

        'monthly_budget':
            category.monthlyBudget,

        'updated_at':
            (category.updatedAt ??
                    DateTime.now())
                .toIso8601String(),
      });

      category.isSynced = true;

      await isar.writeTxn(() async {

        await isar.categoryModels
            .put(category);
      });
    }
  }

  Future<void> pullCategories()
  async {

    final user =
        client.auth.currentUser;

    if (user == null) {
      return;
    }

    final response =
        await client
            .from('categories')
            .select()
            .eq('user_id', user.id);

    for (final item
        in response) {

      final existing =
          await isar.categoryModels
              .get(item['id']);

      final cloudUpdated =
          DateTime.parse(
        item['updated_at'],
      );

      final cloudDeleted =
          item['is_deleted'] ??
              false;

      if (existing == null) {

        if (cloudDeleted) {
          continue;
        }

        final category =
            CategoryModel()

              ..id = item['id']

              ..name =
                  item['name']

              ..type =
                  item['type']

              ..isDefault =
                  item['is_default']

              ..isDeleted =
                  cloudDeleted

              ..updatedAt =
                  cloudUpdated

              ..isSynced = true

              ..monthlyBudget = 
                  item['monthly_budget'];

        await isar.writeTxn(() async {

          await isar.categoryModels
              .put(category);
        });

        continue;
      }

      final localUpdated =
          existing.updatedAt;

      if (localUpdated == null ||
          cloudUpdated.isAfter(
            localUpdated,
          )) {

        existing.name =
            item['name'];

        existing.type =
            item['type'];

        existing.isDefault =
            item['is_default'];

        existing.isDeleted =
            cloudDeleted;

        existing.updatedAt =
            cloudUpdated;

        existing.isSynced = true;

        existing.monthlyBudget = 
            item['monthly_budget'];

        await isar.writeTxn(() async {

          await isar.categoryModels
              .put(existing);
        });
      }
    }
  }

  // =========================================================
  // ACCOUNT SYNC
  // =========================================================

  Future<void> syncAccounts()
  async {

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

    for (final account
        in unsynced) {

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
            (account.updatedAt ??
                    DateTime.now())
                .toIso8601String(),
      });

      account.isSynced = true;

      await isar.writeTxn(() async {

        await isar.accountModels
            .put(account);
      });
    }
  }

  Future<void> pullAccounts()
  async {

    final user =
        client.auth.currentUser;

    if (user == null) {
      return;
    }

    final response =
        await client
            .from('accounts')
            .select()
            .eq('user_id', user.id);

    for (final item
        in response) {

      final existing =
          await isar.accountModels
              .get(item['id']);

      final cloudUpdated =
          DateTime.parse(
        item['updated_at'],
      );

      final cloudDeleted =
          item['is_deleted'] ??
              false;

      if (existing == null) {

        if (cloudDeleted) {
          continue;
        }

        final account =
            AccountModel()

              ..id = item['id']

              ..name =
                  item['name']

              ..type =
                  item['type']

              ..currentBalance =
                  item['current_balance']

              ..isDefault =
                  item['is_default']

              ..isDeleted =
                  cloudDeleted

              ..updatedAt =
                  cloudUpdated

              ..isSynced = true;

        await isar.writeTxn(() async {

          await isar.accountModels
              .put(account);
        });

        continue;
      }

      final localUpdated =
          existing.updatedAt;

      if (localUpdated == null ||
          cloudUpdated.isAfter(
            localUpdated,
          )) {

        existing.name =
            item['name'];

        existing.type =
            item['type'];

        existing.currentBalance =
            item['current_balance'];

        existing.isDefault =
            item['is_default'];

        existing.isDeleted =
            cloudDeleted;

        existing.updatedAt =
            cloudUpdated;

        existing.isSynced = true;

        await isar.writeTxn(() async {

          await isar.accountModels
              .put(existing);
        });
      }
    }
  }

  // =========================================================
  // TRANSACTION SYNC
  // =========================================================

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

        'type':
            transaction.type,

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
            (transaction.updatedAt ??
                  DateTime.now())
              .toIso8601String(), 
      });

      transaction.isSynced = true;

      await isar.writeTxn(() async {

        await isar.transactionModels
            .put(transaction);
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

    for (final item
        in response) {

      final existing =
          await isar.transactionModels
              .get(item['id']);

      final cloudUpdated =
          DateTime.parse(
        item['updated_at'],
      );

      final cloudDeleted =
          item['is_deleted'] ??
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

              ..isDeleted =
                  cloudDeleted

              ..isSynced = true;

        await isar.writeTxn(() async {

          await isar.transactionModels
              .put(transaction);
        });

        continue;
      }

      final localUpdated =
          existing.updatedAt;

      if (localUpdated == null ||
          cloudUpdated.isAfter(
            localUpdated,
          )) {

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

        existing.isDeleted =
            cloudDeleted;

        existing.isSynced = true;

        await isar.writeTxn(() async {

          await isar.transactionModels
              .put(existing);
        });
      }
    }
  }



  // =========================================================
  // RECURRING TRANSACTIONS
  // =========================================================
  Future<void>
      syncRecurringTransactions()
  async {

    final user =
        client.auth.currentUser;

    if (user == null) {
      return;
    }

    // =====================================
    // LOCAL → SUPABASE
    // =====================================

    final unsynced =
        await isar
            .recurringTransactionModels
            .filter()
            .isSyncedEqualTo(false)
            .findAll();

    for (final recurring
        in unsynced) {

      await client
          .from(
            'recurring_transactions',
          )
          .upsert({

        'id':
            recurring.id,

        'user_id':
            user.id,

        'amount':
            recurring.amount,

        'type':
            recurring.type,

        'category_id':
            recurring.categoryId,

        'account_id':
            recurring.accountId,

        'notes':
            recurring.notes,

        'start_date':
            recurring.startDate
                .toIso8601String(),

        'end_date':
            recurring.endDate
                ?.toIso8601String(),

        'frequency':
            recurring.frequency,

        'interval':
            recurring.interval,

        'is_active':
            recurring.isActive,

        'next_run_date':
            recurring.nextRunDate
                .toIso8601String(),

        'updated_at':
            recurring.updatedAt
                .toIso8601String(),

        'is_deleted':
            recurring.isDeleted,
      });

      recurring.isSynced =
          true;

      await isar.writeTxn(
        () async {

          await isar
              .recurringTransactionModels
              .put(recurring);
        },
      );
    }      
  }


  Future<void> pullRecurringTransactions() async {
    final user = client.auth.currentUser;
    if (user == null) {
      return;
    }

    final remote = await client.from('recurring_transactions').select().eq('user_id', user.id);

    for (final item in remote) {
      final local = await isar.recurringTransactionModels.get(item['id']);
      final remoteUpdated = DateTime.parse(item['updated_at']);
      final cloudDeleted = item['is_deleted'] ?? false;

      if (local == null) {
        if (cloudDeleted) {
          continue;
        }

        final recurring = RecurringTransactionModel()
          ..id = item['id']
          ..amount = item['amount']
          ..type = item['type']
          ..categoryId = item['category_id']
          ..accountId = item['account_id']
          ..notes = item['notes']
          ..startDate = DateTime.parse(item['start_date'])
          ..endDate = item['end_date'] != null ? DateTime.parse(item['end_date']) : null
          ..frequency = item['frequency']
          ..interval = item['interval']
          ..isActive = item['is_active']
          ..nextRunDate = DateTime.parse(item['next_run_date'])
          ..updatedAt = remoteUpdated
          ..isDeleted = cloudDeleted
          ..isSynced = true;

        await isar.writeTxn(() async {
          await isar.recurringTransactionModels.put(recurring);
        });

        continue;
      }

      if (remoteUpdated.isAfter(local.updatedAt)) {
        local.amount = item['amount'];
        local.type = item['type'];
        local.categoryId = item['category_id'];
        local.accountId = item['account_id'];
        local.notes = item['notes'];
        local.startDate = DateTime.parse(item['start_date']);
        local.endDate = item['end_date'] != null ? DateTime.parse(item['end_date']) : null;
        local.frequency = item['frequency'];
        local.interval = item['interval'];
        local.isActive = item['is_active'];
        local.nextRunDate = DateTime.parse(item['next_run_date']);
        local.updatedAt = remoteUpdated;
        local.isDeleted = cloudDeleted;
        local.isSynced = true;

        await isar.writeTxn(() async {
          await isar.recurringTransactionModels.put(local);
        });
      }
    }
  }


  // =========================================================
  // INVESTMENT SYNC
  // =========================================================

  Future<void> syncInvestments()
  async {

    final user =
        client.auth.currentUser;

    logger.d(
      'Starting investment sync',
    );

    if (user == null) {
      return;
    }

    final unsynced =
        await isar.investmentModels
            .filter()
            .isSyncedEqualTo(false)
            .findAll();

    for (final investment
        in unsynced) {

      await client
          .from(
            'investments',
          )
          .upsert({

        'id':
            investment.id,

        'user_id':
            user.id,

        'name':
            investment.name,

        'type':
            investment.type,

        'symbol':
            investment.symbol,

        'quantity':
            investment.quantity,

        'purchase_price':
            investment.purchasePrice,

        'current_price':
            investment.currentPrice,

        'purchase_date':
            investment.purchaseDate
                .toIso8601String(),

        'notes':
            investment.notes,

        'is_deleted':
            investment.isDeleted,

        'updated_at':
            (investment.updatedAt)
                .toIso8601String(),
      });

      investment.isSynced = true;

      await isar.writeTxn(() async {

        await isar.investmentModels
            .put(investment);
      });
    }
  }

  Future<void> pullInvestments()
  async {

    final user =
        client.auth.currentUser;

    if (user == null) {
      return;
    }

    final response =
        await client
            .from(
              'investments',
            )
            .select()
            .eq('user_id', user.id);

    for (final item
        in response) {

      final existing =
          await isar.investmentModels
              .get(item['id']);

      final cloudUpdated =
          DateTime.parse(
        item['updated_at'],
      );

      final cloudDeleted =
          item['is_deleted'] ?? false;

      if (existing == null) {

        if (cloudDeleted) {
          continue;
        }

        final investment =
            InvestmentModel()

              ..id = item['id']

              ..name =
                  item['name']

              ..type =
                  item['type']

              ..symbol =
                  item['symbol']

              ..notes =
                  item['notes']

              ..quantity =
                  item['quantity']

              ..purchasePrice =
                  item['purchase_price']

              ..currentPrice =
                  item['current_price']

              ..purchaseDate =
                  DateTime.parse(
                item['purchase_date'],
              )

              ..updatedAt =
                  cloudUpdated

              ..isDeleted =
                  cloudDeleted

              ..isSynced = true;

        await isar.writeTxn(() async {

          await isar.investmentModels
              .put(investment);
        });

        continue;
      }

      
        final localUpdated =
            existing.updatedAt;

        if (
            cloudUpdated.isAfter(
              localUpdated,
            )) {

          existing.name =
              item['name'];

          existing.type =
              item['type'];

          existing.symbol =
              item['symbol'];

          existing.notes =
              item['notes'];

          existing.quantity =
              item['quantity'];

          existing.purchasePrice =
              item['purchase_price'];

          existing.currentPrice =
              item['current_price'];

          existing.purchaseDate =
              DateTime.parse(
            item['purchase_date'],
          );

          existing.updatedAt =
              cloudUpdated;

          existing.isDeleted =
              cloudDeleted;

          existing.isSynced = true;

          await isar.writeTxn(() async {

            await isar.investmentModels
                .put(existing);
          });
        }
          
    }
  }


  // =========================================================
  // Pending Sync Count - Helper to show pending sync count in UI
  // =========================================================
  Future<int>
      getPendingSyncCount()
  async {

    final categories =
        await isar.categoryModels
            .filter()
            .isSyncedEqualTo(false)
            .count();

    final accounts =
        await isar.accountModels
            .filter()
            .isSyncedEqualTo(false)
            .count();

    final transactions =
        await isar.transactionModels
            .filter()
            .isSyncedEqualTo(false)
            .count();

    final recurring =
        await isar
            .recurringTransactionModels
            .filter()
            .isSyncedEqualTo(false)
            .count();

    final investments =
        await isar
            .investmentModels
            .filter()
            .isSyncedEqualTo(false)
            .count();

    return categories +
        accounts +
        transactions +
        recurring +
        investments;
  }

  // =========================================================
  // HELPERS
  // =========================================================

  Future<void> executeSafely(
    Future<void> Function() action,
  ) async {

    try {

      await action();

    } catch (e, stackTrace) {

      LoggerService.error(
        'Sync error: $e',
      );

      logger.e(
        stackTrace.toString(),
      );
    }
  }

  Future<bool> ensureValidSession()
  async {

    final user =
        client.auth.currentUser;

    if (user == null) {

      logger.e(
        'ensureValidSession: no currentUser',
      );

      return false;
    }

    final session =
        client.auth.currentSession;

    if (session == null) {

      logger.e(
        'ensureValidSession: session is null',
      );

      return false;
    }

    if (!session.isExpired) {
      return true;
    }

    logger.d(
      'Session expired, refreshing',
    );

    try {

      final response =
          await client.auth
              .refreshSession();

      return response.session !=
              null &&
          !response
              .session!.isExpired;

    } catch (e) {

      logger.e(
        'Session refresh failed: $e',
      );

      return false;
    }
  }
}