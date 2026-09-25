import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/models/account_model.dart';
import '../../../transactions/presentation/providers/transactions_provider.dart';
import '../../domain/services/account_balance_service.dart';
import 'accounts_provider.dart';

final accountBalancesProvider =
    Provider<AsyncValue<Map<String, int>>>((ref) {
  final accountsAsync = ref.watch(accountsProvider);
  final transactionsAsync = ref.watch(
    transactionsStreamProvider,
  );

  return accountsAsync.when(
    data: (List<AccountModel> accounts) {
      return transactionsAsync.when(
        data: (transactions) {
          final balances = <String, int>{};

          for (final account in accounts) {
            balances[account.uuid] =
                AccountBalanceService.calculate(
              account: account,
              transactions: transactions,
            );
          }

          return AsyncData(balances);
        },
        loading: () =>
            const AsyncLoading<Map<String, int>>(),
        error: (error, stackTrace) =>
            AsyncError<Map<String, int>>(
          error,
          stackTrace,
        ),
      );
    },
    loading: () =>
        const AsyncLoading<Map<String, int>>(),
    error: (error, stackTrace) =>
        AsyncError<Map<String, int>>(
      error,
      stackTrace,
    ),
  );
});
