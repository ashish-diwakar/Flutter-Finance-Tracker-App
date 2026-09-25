import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../accounts/presentation/providers/account_balances_provider.dart';

final totalBalanceProvider = Provider<int>((ref) {
  final balancesAsync =
      ref.watch(accountBalancesProvider);

  final balances =
      balancesAsync.value ?? <String, int>{};

  return balances.values.fold<int>(
    0,
    (sum, balance) => sum + balance,
  );
});
