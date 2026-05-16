import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/providers/database_provider.dart';
import '../../data/repositories/account_repository.dart';

final accountRepositoryProvider =
    FutureProvider<AccountRepository>((ref) async {
  final isar = await ref.watch(isarProvider.future);

  return AccountRepository(isar);
});