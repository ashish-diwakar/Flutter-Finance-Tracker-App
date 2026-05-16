import 'package:isar/isar.dart';

import '../../../../shared/models/category_model.dart';

class CategoryRepository {
  final Isar isar;

  CategoryRepository(this.isar);

  Future<void> addCategory(CategoryModel category) async {
    await isar.writeTxn(() async {
      await isar.categoryModels.put(category);
    });
  }

  Future<List<CategoryModel>> getCategories() async {
    return await isar.categoryModels.where().findAll();
  }
}