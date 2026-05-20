import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/models/transaction_model.dart';
import 'transactions_provider.dart';

enum TransactionLimit {

  last10(
    label: 'Latest 10',
    count: 10,
  ),

  last20(
    label: 'Latest 20',
    count: 20,
  ),

  last50(
    label: 'Latest 50',
    count: 50,
  ),

  last100(
    label: 'Latest 100',
    count: 100,
  ),

  all(
    label: 'All',
    count: null,
  );

  const TransactionLimit({
    required this.label,
    required this.count,
  });

  final String label;

  final int? count;
}

enum TransactionTypeFilter {

  all(
    label: 'All',
    value: null,
  ),

  income(
    label: 'Income',
    value: 'income',
  ),

  expense(
    label: 'Expense',
    value: 'expense',
  );

  const TransactionTypeFilter({
    required this.label,
    required this.value,
  });

  final String label;

  final String? value;
}

class TransactionFilter {

  const TransactionFilter({
    this.limit = TransactionLimit.last10,
    this.type = TransactionTypeFilter.all,
  });

  final TransactionLimit limit;

  final TransactionTypeFilter type;

  TransactionFilter copyWith({
    TransactionLimit? limit,
    TransactionTypeFilter? type,
  }) {

    return TransactionFilter(
      limit: limit ?? this.limit,
      type: type ?? this.type,
    );
  }
}

class TransactionFilterNotifier
    extends StateNotifier<TransactionFilter> {

  TransactionFilterNotifier()
      : super(const TransactionFilter());

  void setLimit(TransactionLimit limit) {
    state = state.copyWith(limit: limit);
  }

  void setType(TransactionTypeFilter type) {
    state = state.copyWith(type: type);
  }
}

final transactionFilterProvider = StateNotifierProvider<
    TransactionFilterNotifier, TransactionFilter>(
  (ref) => TransactionFilterNotifier(),
);

final filteredTransactionsProvider =
    Provider<AsyncValue<List<TransactionModel>>>((ref) {

  final transactionsAsync =
      ref.watch(transactionsStreamProvider);

  final filter =
      ref.watch(transactionFilterProvider);

  return transactionsAsync.whenData((transactions) {

    Iterable<TransactionModel> result = transactions;

    final typeValue = filter.type.value;

    if (typeValue != null) {

      result = result.where(
        (TransactionModel t) => t.type == typeValue,
      );
    }

    final limit = filter.limit.count;

    if (limit != null) {
      result = result.take(limit);
    }

    return result.toList();
  });
});
