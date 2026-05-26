import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/providers/database_provider.dart';
import '../../data/recurring_repository.dart';

final recurringRepositoryProvider =
    FutureProvider(
  (ref) async {

    final isar =
        await ref.read(
      isarProvider.future,
    );

    return RecurringRepository(
      isar,
    );
  },
);

final recurringTransactionsProvider =
    FutureProvider(
  (ref) async {

    final repository =
        await ref.read(
      recurringRepositoryProvider
          .future,
    );

    return repository
        .getAllRecurring();
  },
);