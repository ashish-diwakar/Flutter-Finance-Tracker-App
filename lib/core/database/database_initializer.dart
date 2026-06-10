import 'package:isar_community/isar.dart';

import '../../shared/models/category_model.dart';
import '../../shared/models/account_model.dart';
import 'default_data.dart';

class DatabaseInitializer {

  static Future<void> seedDatabase(Isar isar) async {

    final categoriesCount =
        await isar.categoryModels.count();

    if (categoriesCount == 0) {
      await isar.writeTxn(() async {
        await isar.categoryModels.putAll(
          DefaultData.categories,
        );
      });
    }

    final accountsCount =
        await isar.accountModels.count();

    if (accountsCount == 0) {
      await isar.writeTxn(() async {
        await isar.accountModels.putAll(
          DefaultData.accounts,
        );
      });
    }
  }
}