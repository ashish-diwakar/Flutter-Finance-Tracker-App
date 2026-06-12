import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/providers/database_provider.dart';
import '../../data/repositories/goal_repository.dart';

final goalRepositoryProvider =
    FutureProvider<GoalRepository>(
  (ref) async {

    final isar =
        await ref.watch(
      isarProvider.future,
    );

    return GoalRepository(
      isar,
    );
  },
);