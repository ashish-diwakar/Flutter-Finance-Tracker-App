import 'package:finance_tracker/shared/providers/database_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar_community/isar.dart';

import '../../../../shared/models/category_model.dart';
import 'category_repository_provider.dart';

final categoriesProvider =
    FutureProvider.family<List<CategoryModel>, String>(
        (ref, type) async {

  final repository =
      await ref.watch(
        categoryRepositoryProvider.future,
      );

  return repository.getCategoriesByType(type);
});

final allCategoriesProvider =
    FutureProvider<List<CategoryModel>>((ref) async {

  final isar = await ref.watch(
    isarProvider.future,
  );

  return isar.categoryModels
      .filter()
      .isDeletedEqualTo(false)
      .findAll();
});