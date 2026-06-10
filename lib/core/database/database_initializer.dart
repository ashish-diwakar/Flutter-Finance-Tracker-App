import 'package:finance_tracker/shared/utils/default_data_uuid_fixer.dart';
import 'package:isar_community/isar.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../shared/models/category_model.dart';
import '../../shared/models/account_model.dart';
import 'default_data.dart';

class DatabaseInitializer {

  static Future<void> seedDatabase(Isar isar) async {

    final categoriesCount =
        await isar.categoryModels.count();

    final accountsCount =
        await isar.accountModels.count();

    if (categoriesCount == 0 || accountsCount == 0) {
    
        final user =
            Supabase.instance.client.auth.currentUser;

        if (user == null) {
              return;
        }

        // ==========================================
        // CHECK SUPABASE CATEGORIES
        // ==========================================

        final remoteCategories =
            await Supabase.instance.client
                .from('categories')
                .select('id')
                .eq(
                  'user_id',
                  user.id,
                )
                .limit(1);

        // ==========================================
        // CHECK SUPABASE ACCOUNTS
        // ==========================================

        final remoteAccounts =
            await Supabase.instance.client
                .from('accounts')
                .select('id')
                .eq(
                  'user_id',
                  user.id,
                )
                .limit(1);

        final hasRemoteCategories =
            remoteCategories.isNotEmpty;

        final hasRemoteAccounts =
            remoteAccounts.isNotEmpty;

        // User already has data in cloud
        if (
          hasRemoteCategories &&
          hasRemoteAccounts
        ) {
          return;
        }

        if (categoriesCount == 0 && !hasRemoteCategories) {
          DefaultData.categories = fixUuidForCategoryList(DefaultData.categories);
          await isar.writeTxn(() async {
            await isar.categoryModels.putAll(
              DefaultData.categories,
            );
          });
        }

        if (accountsCount == 0 && !hasRemoteAccounts) {
          DefaultData.accounts = fixUuidForAccountList(DefaultData.accounts);
          await isar.writeTxn(() async {
            await isar.accountModels.putAll(
              DefaultData.accounts,
            );
          });
        }
    }
  }
}