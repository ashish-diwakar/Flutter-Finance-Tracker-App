import 'package:isar/isar.dart';

import '../../../../shared/models/category_model.dart';

class CategoryRepository {

  final Isar isar;

  CategoryRepository(this.isar);

  Future<List<CategoryModel>> getCategoriesByType(
    String type,
  ) async {

    return await isar.categoryModels
        .filter()
        .typeEqualTo(type)
        .findAll();
  }
}