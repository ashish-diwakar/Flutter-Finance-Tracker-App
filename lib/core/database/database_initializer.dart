import 'package:isar/isar.dart';

import '../../shared/models/category_model.dart';
import 'default_data.dart';

class DatabaseInitializer {
  static Future<void> seedDefaultCategories(Isar isar) async {
    final existing = await isar.categoryModels.count();

    if (existing > 0) {
      return;
    }

    await isar.writeTxn(() async {
      await isar.categoryModels.putAll(
        DefaultData.categories,
      );
    });
  }
}