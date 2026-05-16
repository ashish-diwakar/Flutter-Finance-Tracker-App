import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/providers/database_provider.dart';
import '../../data/repositories/transaction_repository.dart';

final transactionRepositoryProvider =
    FutureProvider<TransactionRepository>((ref) async {
  final isar = await ref.watch(isarProvider.future);

  return TransactionRepository(isar);
});