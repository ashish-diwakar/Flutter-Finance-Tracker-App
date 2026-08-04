import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'transaction_filter_provider.dart';

class TransactionSummary {

  final int income;
  final int expense;

  const TransactionSummary({
    required this.income,
    required this.expense,
  });

  int get balance => income - expense;
}

final transactionSummaryProvider =
    Provider<AsyncValue<TransactionSummary>>((ref) {

  final transactionsAsync =
      ref.watch(filteredTransactionsProvider);

  return transactionsAsync.whenData((transactions) {

    int income = 0;
    int expense = 0;

    for (final transaction in transactions) {

      if (transaction.type == 'income') {
        income += transaction.amount;
      } else {
        expense += transaction.amount;
      }
    }

    return TransactionSummary(
      income: income,
      expense: expense,
    );
  });
});