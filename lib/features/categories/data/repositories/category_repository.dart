import 'package:isar_community/isar.dart';

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
        DateTime.now().toUtc();

    category.isSynced = false;

    await isar.writeTxn(() async {

      await isar.categoryModels.put(
        category,
      );
    });
  }

  Future<void> deleteCategory(
    CategoryModel category,
  ) async {

    if (category.isDefault) {

      throw StateError(
        'Default categories cannot be deleted.',
      );
    }

    category.isDeleted = true;

    category.isSynced = false;

    category.updatedAt =
        DateTime.now().toUtc();

    await isar.writeTxn(() async {

      await isar.categoryModels.put(
        category,
      );
    });
    // await isar.writeTxn(() async {

    //   await isar.categoryModels.delete(
    //     category.id,
    //   );
    // });
  }
}