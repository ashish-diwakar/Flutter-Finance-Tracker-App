import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'transaction_filter_provider.dart';

class TransactionSummary {
  final int income;
  final int expense;
  final int balance;

  const TransactionSummary({
    required this.income,
    required this.expense,
    required this.balance,
  });
}

final transactionSummaryProvider =
    Provider<AsyncValue<TransactionSummary>>((ref) {
  final transactionsAsync =
      ref.watch(filteredTransactionsProvider);

  return transactionsAsync.whenData((transactions) {
    int income = 0;
    int expense = 0;
    int balance = 0;

    for (final transaction in transactions) {
      switch (transaction.type) {
        case 'income':
          income += transaction.amount;
          balance += transaction.amount;
          break;

        case 'expense':
          expense += transaction.amount;
          balance -= transaction.amount;
          break;

        case 'borrowed':
          balance += transaction.amount;
          break;

        case 'lent':
          balance -= transaction.amount;
          break;

        case 'repaymentPaid':
          balance -= transaction.amount;
          break;

        case 'repaymentReceived':
          balance += transaction.amount;
          break;

        case 'transfer':
          // A transfer moves money between the user's own accounts,
          // so it does not change the overall transaction balance.
          break;

        default:
          break;
      }
    }

    return TransactionSummary(
      income: income,
      expense: expense,
      balance: balance,
    );
  });
});
