import 'package:isar/isar.dart';

import '../../../../shared/models/category_model.dart';

class CategoryRepository {

  final Isar isar;

  CategoryRepository(this.isar);

  Future<List<CategoryModel>>
      getCategoriesByType(
    String type,
  ) async {

    return await isar.categoryModels
        .filter()
        .typeEqualTo(type)
        .findAll();
  }

  Future<List<CategoryModel>>
      getAllCategories() async {

    return await isar.categoryModels
        .where()
        .findAll();
  }

  Future<void> addCategory(
    CategoryModel category,
  ) async {

    await isar.writeTxn(() async {

      await isar.categoryModels.put(
        category,
      );
    });
  }

  Future<void> updateCategory(
    CategoryModel category,
  ) async {

    category.updatedAt =
        DateTime.now();

    category.isSynced = false;

    await isar.writeTxn(() async {

      await isar.categoryModels.put(
        category,
      );
    });
  }

  Future<void> deleteCategory(
    int id,
  ) async {

    await isar.writeTxn(() async {

      await isar.categoryModels.delete(
        id,
      );
    });
  }
}