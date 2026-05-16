import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/providers/database_provider.dart';
import '../../data/repositories/category_repository.dart';

final categoryRepositoryProvider =
    FutureProvider<CategoryRepository>((ref) async {
  final isar = await ref.watch(isarProvider.future);

  return CategoryRepository(isar);
});