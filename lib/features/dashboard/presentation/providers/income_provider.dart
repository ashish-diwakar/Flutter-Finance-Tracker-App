import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../transactions/presentation/providers/transaction_repository_provider.dart';

final totalIncomeProvider = FutureProvider<int>((ref) async {

  final repository =
      await ref.watch(
        transactionRepositoryProvider.future,
      );

  return repository.getTotalIncome();
});