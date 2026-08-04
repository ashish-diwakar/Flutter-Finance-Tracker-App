import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/models/transaction_model.dart';
import '../../../transactions/presentation/providers/transaction_repository_provider.dart';

final transactionsStreamProvider =
    StreamProvider<List<TransactionModel>>((ref) async* {

  final repository =
      await ref.watch(
        transactionRepositoryProvider.future,
      );

  yield* repository.watchTransactions();
});