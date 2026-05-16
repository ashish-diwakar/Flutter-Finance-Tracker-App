import 'package:flutter_riverpod/flutter_riverpod.dart';

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