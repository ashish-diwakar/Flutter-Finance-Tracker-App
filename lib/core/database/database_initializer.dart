import 'package:finance_tracker/shared/utils/default_data_uuid_fixer.dart';
import 'package:isar_community/isar.dart';

import '../../shared/models/account_model.dart';
import '../../shared/models/category_model.dart';
import 'default_data.dart';

class DatabaseInitializer {

  static Future<void> seedDatabase(Isar isar) async {

    final categoriesCount =
        await isar.categoryModels.count();

    final accountsCount =
        await isar.accountModels.count();

    if (categoriesCount == 0) {

      final categories =
          fixUuidForCategoryList(
        DefaultData.categories,
      );

      await isar.writeTxn(() async {

        await isar.categoryModels.putAll(
          categories,
        );
      });
    }

    if (accountsCount == 0) {

      final accounts =
          fixUuidForAccountList(
        DefaultData.accounts,
      );

      await isar.writeTxn(() async {

        await isar.accountModels.putAll(
          accounts,
        );
      });
    }
  }
}