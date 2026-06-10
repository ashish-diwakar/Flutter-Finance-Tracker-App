import 'package:finance_tracker/main.dart';
import 'package:isar_community/isar.dart';

import '../../../../core/services/logger_service.dart';
import '../../../../core/services/supabase_service.dart';
import '../../../../shared/models/account_model.dart';
import '../../../../shared/models/category_model.dart';
import '../../../../shared/models/transaction_model.dart';
import '../../../../shared/models/recurring_transaction_model.dart';
import '../../../../shared/models/investment_model.dart';
import '../../../../shared/utils/device_name_helper.dart';

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

    bool success = true;

    success &= await executeSafely(syncCategories);
    success &= await executeSafely(pullCategories);

    
    success &= await executeSafely(syncAccounts);
    success &= await executeSafely(pullAccounts);

    
    success &= await executeSafely(syncRecurringTransactions);
    success &= await executeSafely(pullRecurringTransactions);

    
    success &= await executeSafely(syncTransactions);
    success &= await executeSafely(pullTransactions);

    
    success &= await executeSafely(syncInvestments);
    success &= await executeSafely(pullInvestments);

    // await executeSafely(
    //   syncCategories,
    // );

    // await executeSafely(
    //   pullCategories,
    // );

    // await executeSafely(
    //   syncAccounts,
    // );

    // await executeSafely(
    //   pullAccounts,
    // );

    // await executeSafely(
    //   syncRecurringTransactions,
    // );

    //  await executeSafely(
    //   pullRecurringTransactions,
    // );

    // await executeSafely(
    //   syncTransactions,
    // );

    // await executeSafely(
    //   pullTransactions,
    // );

    // await executeSafely(
    //   syncInvestments,
    // );
    // await executeSafely(
    //   pullInvestments,
    // );

    // await client
    //     .from('sync_metadata')
    //     .upsert({
    //   'user_id':
    //       client.auth.currentUser!.id,
    //   'last_sync_at':
    //       DateTime.now()
    //           .toIso8601String(),
    //   'last_device':
    //       getCurrentDevice(),
    // });

    if (success) {
      await client
          .from('sync_metadata')
          .upsert({
        'user_id':
            client.auth.currentUser!.id,
        'last_sync_at':
            DateTime.now()
                .toIso8601String(),
        'last_device':
            getCurrentDevice(),
      });
    }

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

    // final unsynced =
    //     await isar.categoryModels
    //         .filter()
    //         .isSyncedEqualTo(false)
    //         .findAll();

    // for (final category
    //     in unsynced) {
    // logger.d(
    //   '----------------------------------------------------------------------------------------------', 
    // );
    // logger.d(
    //   'category to sync ${category.name}, ${category.type}, ${category.isDefault}, ${category.monthlyBudget},', 
    // );


    //   await client
    //       .from('categories')
    //       .upsert({

    //     'id': category.id,

    //     'user_id': user.id,

    //     'name': category.name,

    //     'type': category.type,

    //     'is_default':
    //         category.isDefault,

    //     'is_deleted':
    //         category.isDeleted,

    //     'monthly_budget':
    //         category.monthlyBudget,

    //     'updated_at':
    //         (category.updatedAt ??
    //                 DateTime.now())
    //             .toIso8601String(),
    //   });

    //   category.isSynced = true;

    //   await isar.writeTxn(() async {

    //     await isar.categoryModels
    //         .put(category);
    //   });
    // }

    final unsynced =
          await isar.categoryModels
              .filter()
              .isSyncedEqualTo(false)
              .findAll();

      if (unsynced.isEmpty) {
        return;
      }

      logger.d(
        'Current auth user: ${client.auth.currentUser?.id}',
      );

      logger.d(
        'Row user_id: ${user.id}',
      );

      for (final category in unsynced) {

        logger.d(
          '----------------------------------------------------------------------------------------------',
        );
        logger.d(
          'Category ID: ${category.uuid}',
        );
        logger.d(
          'category to sync ${category.name}, ${category.type}, ${category.isDefault}, ${category.monthlyBudget}',
        );
      }



      await client
          .from('categories')
          .upsert(

            unsynced.map((category) => {

              'id': category.uuid,

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
            }).toList(),
          );

      await isar.writeTxn(() async {

        for (final category
            in unsynced) {

          category.isSynced = true;

          logger.d(
            'Category ${category.name} -> user_id=${user.id}',
          );
        }

        await isar.categoryModels
            .putAll(unsynced);

          logger.d(
            'Category Sync Completed!!!!!!!!!!!!!!!!!!!!!!!!!',
          );
      });
  }

  Future<void> pullCategories()
  async {

    final user =
        client.auth.currentUser;

    if (user == null) {
      return;
    }

    logger.d(
      'Category Pull Started!!!!!!!!!!!!!!!!!!!!!!!!!',
    );

    final response =
        await client
            .from('categories')
            .select()
            .eq('user_id', user.id);

    for (final item
        in response) {

      final existing =
        await isar.categoryModels
            .filter()
            .uuidEqualTo(item['id'])
            .findFirst();

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

              ..uuid  = item['id']

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
          logger.d(
            'Category Pull Completed!!!!!!!!!!!!!!!!!!!!!!!!!',
          );
      }
    }
  }

  // =========================================================
  // ACCOUNT SYNC
  // =========================================================

  // Future<void> syncAccounts()
  // async {

  //   final user =
  //       client.auth.currentUser;

  //   if (user == null) {
  //     return;
  //   }

  //   final unsynced =
  //       await isar.accountModels
  //           .filter()
  //           .isSyncedEqualTo(false)
  //           .findAll();

  //   for (final account
  //       in unsynced) {

  //     await client
  //         .from('accounts')
  //         .upsert({

  //       'id': account.id,

  //       'user_id': user.id,

  //       'name': account.name,

  //       'type': account.type,

  //       'current_balance':
  //           account.currentBalance,

  //       'is_default':
  //           account.isDefault,

  //       'is_deleted':
  //           account.isDeleted,

  //       'updated_at':
  //           (account.updatedAt ??
  //                   DateTime.now())
  //               .toIso8601String(),
  //     });

  //     account.isSynced = true;

  //     await isar.writeTxn(() async {

  //       await isar.accountModels
  //           .put(account);
  //     });
  //   }
  // }
  Future<void> syncAccounts()
  async {

    final user =
        client.auth.currentUser;

    if (user == null) {
      return;
    }

    logger.d(
      'Account Sync Started!!!!!!!!!!!!!!!!!!!!!!!!!',
    );
    final unsynced =
        await isar.accountModels
            .filter()
            .isSyncedEqualTo(false)
            .findAll();

    if (unsynced.isEmpty) {
      return;
    }

    await client
        .from('accounts')
        .upsert(

          unsynced.map((account) => {

            'id': account.uuid,

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
          }).toList(),
        );

    await isar.writeTxn(() async {

      for (final account
          in unsynced) {

        account.isSynced = true;
          
          logger.d(
            'Account ${account.name} -> user_id=${user.id}',
          );
      }

      await isar.accountModels
          .putAll(unsynced);

      logger.d(
        'Account Sync Completed!!!!!!!!!!!!!!!!!!!!!!!!!',
      );

    });
  }

  Future<void> pullAccounts()
  async {

    final user =
        client.auth.currentUser;

    if (user == null) {
      return;
    }
    logger.d(
      'Account Pull Started!!!!!!!!!!!!!!!!!!!!!!!!!',
    );

    final response =
        await client
            .from('accounts')
            .select()
            .eq('user_id', user.id);

    for (final item
        in response) {

      final existing =
        await isar.accountModels
            .filter()
            .uuidEqualTo(item['id'])
            .findFirst();

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

              ..uuid  = item['id']

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
        
        logger.d(
          'Account Pull Completed!!!!!!!!!!!!!!!!!!!!!!!!!',
        );
      }
    }
  }

  // =========================================================
  // TRANSACTION SYNC
  // =========================================================

  // Future<void> syncTransactions()
  // async {

  //   final user =
  //       client.auth.currentUser;

  //   if (user == null) {
  //     return;
  //   }

  //   final unsynced =
  //       await isar.transactionModels
  //           .filter()
  //           .isSyncedEqualTo(false)
  //           .findAll();

  //   for (final transaction
  //       in unsynced) {

  //     await client
  //         .from('transactions')
  //         .upsert({

  //       'id': transaction.id,

  //       'user_id': user.id,

  //       'amount':
  //           transaction.amount,

  //       'type':
  //           transaction.type,

  //       'category_id':
  //           transaction.categoryId,

  //       'account_id':
  //           transaction.accountId,

  //       'notes':
  //           transaction.notes,

  //       'transaction_date':
  //           transaction
  //               .transactionDate
  //               .toIso8601String(),

  //       'is_deleted':
  //           transaction.isDeleted,

  //       'updated_at':
  //           (transaction.updatedAt ??
  //                 DateTime.now())
  //             .toIso8601String(), 
  //     });

  //     transaction.isSynced = true;

  //     await isar.writeTxn(() async {

  //       await isar.transactionModels
  //           .put(transaction);
  //     });
  //   }
  // }
  Future<void> syncTransactions()
  async {

    final user =
        client.auth.currentUser;

    if (user == null) {
      return;
    }

    logger.d(
      'Transaction Sync Started!!!!!!!!!!!!!!!!!!!!!!!!!',
    );
    final unsynced =
        await isar.transactionModels
            .filter()
            .isSyncedEqualTo(false)
            .findAll();

    if (unsynced.isEmpty) {
      return;
    }

    await client
        .from('transactions')
        .upsert(

          unsynced.map((transaction) => {

            'id': transaction.uuid,

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
          }).toList(),
        );

    await isar.writeTxn(() async {

      for (final transaction
          in unsynced) {

        transaction.isSynced = true;
      }

      await isar.transactionModels
          .putAll(unsynced);

      logger.d(
        'Transaction Sync Completed!!!!!!!!!!!!!!!!!!!!!!!!!',
      );
    });
  }

  Future<void> pullTransactions()
  async {

    final user =
        client.auth.currentUser;

    if (user == null) {
      return;
    }

    logger.d(
      'Transaction Pull Started!!!!!!!!!!!!!!!!!!!!!!!!!',
    );

    final response =
        await client
            .from('transactions')
            .select()
            .eq('user_id', user.id);

    for (final item
        in response) {

      final existing =
        await isar.transactionModels
            .filter()
            .uuidEqualTo(item['id'])
            .findFirst();

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

              ..uuid  = item['id']

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
    logger.d(
      'Transaction Pull Completed!!!!!!!!!!!!!!!!!!!!!!!!!',
    );
  }



  // =========================================================
  // RECURRING TRANSACTIONS
  // =========================================================
  // Future<void>
  //     syncRecurringTransactions()
  // async {

  //   final user =
  //       client.auth.currentUser;

  //   if (user == null) {
  //     return;
  //   }

  //   // =====================================
  //   // LOCAL → SUPABASE
  //   // =====================================

  //   final unsynced =
  //       await isar
  //           .recurringTransactionModels
  //           .filter()
  //           .isSyncedEqualTo(false)
  //           .findAll();

  //   for (final recurring
  //       in unsynced) {

  //     await client
  //         .from(
  //           'recurring_transactions',
  //         )
  //         .upsert({

  //       'id':
  //           recurring.id,

  //       'user_id':
  //           user.id,

  //       'amount':
  //           recurring.amount,

  //       'type':
  //           recurring.type,

  //       'category_id':
  //           recurring.categoryId,

  //       'account_id':
  //           recurring.accountId,

  //       'notes':
  //           recurring.notes,

  //       'start_date':
  //           recurring.startDate
  //               .toIso8601String(),

  //       'end_date':
  //           recurring.endDate
  //               ?.toIso8601String(),

  //       'frequency':
  //           recurring.frequency,

  //       'interval':
  //           recurring.interval,

  //       'is_active':
  //           recurring.isActive,

  //       'next_run_date':
  //           recurring.nextRunDate
  //               .toIso8601String(),

  //       'updated_at':
  //           recurring.updatedAt
  //               .toIso8601String(),

  //       'is_deleted':
  //           recurring.isDeleted,
  //     });

  //     recurring.isSynced =
  //         true;

  //     await isar.writeTxn(
  //       () async {

  //         await isar
  //             .recurringTransactionModels
  //             .put(recurring);
  //       },
  //     );
  //   }      
  // }
  Future<void>
      syncRecurringTransactions()
  async {

    final user =
        client.auth.currentUser;

    if (user == null) {
      return;
    }

    logger.d(
      'Recurring Transaction Sync Started!!!!!!!!!!!!!!!!!!!!!!!!!',
    );

    // =====================================
    // LOCAL → SUPABASE
    // =====================================

    final unsynced =
        await isar
            .recurringTransactionModels
            .filter()
            .isSyncedEqualTo(false)
            .findAll();

    if (unsynced.isEmpty) {
      return;
    }

    await client
        .from(
          'recurring_transactions',
        )
        .upsert(

          unsynced.map((recurring) => {

            'id':
                recurring.uuid,

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
          }).toList(),
        );

    await isar.writeTxn(
      () async {

        for (final recurring
            in unsynced) {

          logger.d(
            'Recurring Transaction Sync --- ${recurring.uuid} -> user_id=${user.id}, amount=${recurring.amount}, type=${recurring.type}, categoryId=${recurring.categoryId}, accountId=${recurring.accountId}, notes=${recurring.notes}, startDate=${recurring.startDate}, endDate=${recurring.endDate}, frequency=${recurring.frequency}, interval=${recurring.interval}, isActive=${recurring.isActive}, nextRunDate=${recurring.nextRunDate}, updatedAt=${recurring.updatedAt}, isDeleted=${recurring.isDeleted}',
          );

          recurring.isSynced =
              true;
        }

        await isar
            .recurringTransactionModels
            .putAll(
              unsynced,
            );
          logger.d(
            'Recurring Transaction Sync Completed!!!!!!!!!!!!!!!!!!!!!!!!!',
          );
      },
    );
  }


  Future<void> pullRecurringTransactions() async {
    final user = client.auth.currentUser;
    logger.d(
      'Recurring Transaction Pull Started!!!!!!!!!!!!!!!!!!!!!!!!!',
    );
    if (user == null) {
      return;
    }

    final remote = await client.from('recurring_transactions').select().eq('user_id', user.id);

    for (final item in remote) {
      final local =
        await isar.recurringTransactionModels
            .filter()
            .uuidEqualTo(item['id'])
            .findFirst();
      final remoteUpdated = DateTime.parse(item['updated_at']);
      final cloudDeleted = item['is_deleted'] ?? false;

      if (local == null) {
        if (cloudDeleted) {
          continue;
        }

        final recurring = RecurringTransactionModel()
          ..uuid  = item['id']
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
    logger.d(
      'Recurring Transaction Pull Completed!!!!!!!!!!!!!!!!!!!!!!!!!',
    );
  }


  // =========================================================
  // INVESTMENT SYNC
  // =========================================================

  Future<int> syncInvestments()
  async {

    final user =
        client.auth.currentUser;

    logger.d(
      'Starting investment sync',
    );

    if (user == null) {
      return 0;
    }

    logger.d(
      'Investment Sync Started!!!!!!!!!!!!!!!!!!!!!!!!!',
    );

    // final unsynced =
    //     await isar.investmentModels
    //         .filter()
    //         .isSyncedEqualTo(false)
    //         .findAll();

    // for (final investment
    //     in unsynced) {

    //   await client
    //       .from(
    //         'investments',
    //       )
    //       .upsert({

    //     'id':
    //         investment.id,

    //     'user_id':
    //         user.id,

    //     'name':
    //         investment.name,

    //     'type':
    //         investment.type,

    //     'symbol':
    //         investment.symbol,

    //     'quantity':
    //         investment.quantity,

    //     'purchase_price':
    //         investment.purchasePrice,

    //     'current_price':
    //         investment.currentPrice,

    //     'purchase_date':
    //         investment.purchaseDate
    //             .toIso8601String(),

    //     'notes':
    //         investment.notes,

    //     'is_deleted':
    //         investment.isDeleted,

    //     'updated_at':
    //         (investment.updatedAt)
    //             .toIso8601String(),
    //   });

    //   investment.isSynced = true;

    //   await isar.writeTxn(() async {

    //     await isar.investmentModels
    //         .put(investment);
    //   });
    // }

    final investments =
        await isar.investmentModels
            .filter()
            //.isDeletedEqualTo(false)
            .isSyncedEqualTo(false)
            .findAll();

    if (investments.isNotEmpty) {

        await client
            .from('investments')
            .upsert(

              investments.map(
                (investment) => {

                  'id': investment.uuid,

                  'user_id': user.id,

                  'name': investment.name,

                  'type': investment.type,

                  'symbol': investment.symbol,

                  'quantity': investment.quantity,

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
                      investment.updatedAt
                          .toIso8601String(),
                },
              ).toList(),
            );

        await isar.writeTxn(() async {

          for (final investment
              in investments) {

            investment.isSynced =
                true;

            investment.updatedAt =
                DateTime.now();

          }

          await isar
              .investmentModels
              .putAll(
            investments,
          );
        logger.d(
          'Investment Sync Completed!!!!!!!!!!!!!!!!!!!!!!!!!',
        );
        });
      }
    return investments.length;
  }

  Future<void> pullInvestments()
  async {

    final user =
        client.auth.currentUser;

    logger.d(
      'Starting investment pull',
    );

    if (user == null) {
      logger.d(
        'User is null, aborting investment pull',
      );
      return;
    }
    
    // logger.d(
    //   'Step 2 investment pull',
    // );

    logger.d(
      'Investment Pull Started!!!!!!!!!!!!!!!!!!!!!!!!!',
    );

    final response =
        await client
            .from(
              'investments',
            )
            .select()
            .eq('user_id', user.id);

    // logger.d(
    //   'Step 2 investment pull ${response.length} items.',
    // );

    for (final item
        in response) {

      final existing =
        await isar.investmentModels
            .filter()
            .uuidEqualTo(item['id'])
            .findFirst();

      final cloudUpdated =
          DateTime.parse(
        item['updated_at'],
      );

      final cloudDeleted =
          item['is_deleted'] ?? false;

      if (existing == null) {
        // logger.d(
        //   'Step 3 investment pull existing is null',
        // );

        if (cloudDeleted) {
          continue;
        }

        final investment =
            InvestmentModel()

              ..uuid  = item['id']

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

        // logger.d(
        //   'Step 5 investment pull updating ${investment.name}. Cloud updated: ${cloudUpdated.toIso8601String()}, Local updated: ${investment.updatedAt.toIso8601String()}',
        // );
        await isar.writeTxn(() async {

          await isar.investmentModels
              .put(investment);
        });

        continue;
      }

        // logger.d(
        //   'Step 4 investment pull existing is not null',
        // );
      
        final localUpdated =
            existing.updatedAt;

        
        // logger.d(
        //   'Step 4a investment pull existing is not null ${cloudUpdated.toIso8601String()} vs ${localUpdated.toIso8601String() }',
        // );
      

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

        // logger.d(
        //   'Step 5 investment pull updating ${existing.name}. Cloud updated: ${cloudUpdated.toIso8601String()}, Local updated: ${localUpdated.toIso8601String()}',
        // );

          await isar.writeTxn(() async {

            await isar.investmentModels
                .put(existing);
          });
        }
          
    }
    logger.d(
      'Investment Pull Completed!!!!!!!!!!!!!!!!!!!!!!!!!',
    );
  }


  // =========================================================
  // Pending Sync Count - Helper to show pending sync count in UI
  // =========================================================
  Future<int>
      getPendingSyncCount()
  async {

    // final categories =
    //     await isar.categoryModels
    //         .filter()
    //         .isSyncedEqualTo(false)
    //         .count();

    // final accounts =
    //     await isar.accountModels
    //         .filter()
    //         .isSyncedEqualTo(false)
    //         .count();

    // final transactions =
    //     await isar.transactionModels
    //         .filter()
    //         .isSyncedEqualTo(false)
    //         .count();

    // final recurring =
    //     await isar
    //         .recurringTransactionModels
    //         .filter()
    //         .isSyncedEqualTo(false)
    //         .count();

    // final investments =
    //     await isar
    //         .investmentModels
    //         .filter()
    //         .isSyncedEqualTo(false)
    //         .count();

    // return categories +
    //     accounts +
    //     transactions +
    //     recurring +
    //     investments;

    logger.d(
      'Get Pending Sync Count Started!!!!!!!!!!!!!!!!!!!!!!!!!',
    );

    final results = await Future.wait([
        isar.categoryModels
            .filter()
            .isSyncedEqualTo(false)
            .count(),

        isar.accountModels
            .filter()
            .isSyncedEqualTo(false)
            .count(),

        isar.transactionModels
            .filter()
            .isSyncedEqualTo(false)
            .count(),

        isar.recurringTransactionModels
            .filter()
            .isSyncedEqualTo(false)
            .count(),

        isar.investmentModels
            .filter()
            .isSyncedEqualTo(false)
            .count(),
      ]);

      int total = 0;

      for (final count in results) {
        total += count;
      }

      logger.d(
        'Get Pending Sync Count Completed!!!!!!!!!!!!!!!!!!!!!!!!!',
      );

      return total;
  }

  // =========================================================
  // HELPERS
  // =========================================================

  // Future<void> executeSafely(
  //   Future<void> Function() action,
  // ) async {

  //   try {

  //     await action();

  //   } catch (e, stackTrace) {

  //     LoggerService.error(
  //       'Sync error: $e',
  //     );

  //     logger.e(
  //       stackTrace.toString(),
  //     );
  //   }
  // }
  Future<bool> executeSafely(
    Future<void> Function() action,
  ) async {
    try {
      await action();
      return true;
    } catch (e, stackTrace) {

      
      LoggerService.error(
        'Sync error: $e',
      );

      logger.e(
        stackTrace.toString(),
      );

      return false;
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