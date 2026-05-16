import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';

import '../../core/database/database_initializer.dart';
import '../../core/database/isar_service.dart';

final isarProvider = FutureProvider<Isar>((ref) async {
  final isar = await IsarService.openIsar();

  await DatabaseInitializer.seedDefaultCategories(isar);

  return isar;
});