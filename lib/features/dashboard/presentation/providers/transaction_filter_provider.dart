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

  final TransactionLimit limit;

  final TransactionTypeFilter type;

  final String searchText;

  final String? categoryId;

  final String? accountId;

  final DateTime? fromDate;

  final DateTime? toDate;

  const TransactionFilter({

    this.limit = TransactionLimit.last10,

    this.type = TransactionTypeFilter.all,

    this.searchText = '',

    this.categoryId,

    this.accountId,

    this.fromDate,

    this.toDate,
  });


  TransactionFilter copyWith({
    TransactionLimit? limit,
    TransactionTypeFilter? type,
    String? searchText,
    String? categoryId,
    String? accountId,
    DateTime? fromDate,
    DateTime? toDate,
  }) {

    return TransactionFilter(
      limit: limit ?? this.limit,
      type: type ?? this.type,
      searchText: searchText ?? this.searchText,
      categoryId: categoryId ?? this.categoryId,
      accountId: accountId ?? this.accountId,
      fromDate: fromDate ?? this.fromDate,
      toDate: toDate ?? this.toDate,
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

  void setSearchText(String searchText) {
    state = state.copyWith(searchText: searchText);
  }

  void setCategoryId(String? categoryId) {
    state = state.copyWith(categoryId: categoryId);
  }

  void setAccountId(String? accountId) {
    state = state.copyWith(accountId: accountId);
  }

  void setFromDate(DateTime? fromDate) {
    state = state.copyWith(fromDate: fromDate);
  }

  void setToDate(DateTime? toDate) {
    state = state.copyWith(toDate: toDate);
  }
  void clearFilters() {
    state = const TransactionFilter();
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

    if (filter.searchText.trim().isNotEmpty) {
      // result = result.where(
      //   (t) =>
      //     t.notes
      //         ?.toLowerCase()
      //         .contains(
      //           filter.searchText
      //               .toLowerCase(),
      //         ) ??
      //     false,
      // );      
      final search =
          filter.searchText
              .toLowerCase()
              .trim();

      result = result.where((t) {

        return

            (t.notes ?? '')
                .toLowerCase()
                .contains(search)

            ||

            t.type
                .toLowerCase()
                .contains(search)

            ||

            (t.amount / 100)
                .toString()
                .contains(search);
      });
    }

    if (filter.categoryId != null) {
      result = result.where(
        (t) => t.categoryId == filter.categoryId,
      );
    }

    if (filter.accountId != null) {
      result = result.where(
        (t) => t.accountId == filter.accountId,
      );
    }

    if (filter.fromDate != null) {
      final startOfDay = DateTime(
        filter.fromDate!.year,
        filter.fromDate!.month,
        filter.fromDate!.day,
      );

      result = result.where(
        (t) => !t.transactionDate.isBefore(startOfDay),
      );
    }

    if (filter.toDate != null) {

      // final endOfDay = DateTime(
      //   filter.toDate!.year,
      //   filter.toDate!.month,
      //   filter.toDate!.day,
      //   23,
      //   59,
      //   59,
      //   999,
      // );
      // result = result.where(
      //   (t) => !t.transactionDate.isAfter(endOfDay),
      // );
      
      final endOfDay = DateTime(
        filter.toDate!.year,
        filter.toDate!.month,
        filter.toDate!.day + 1,
      );

      result = result.where(
        (t) => t.transactionDate.isBefore(endOfDay),
      );
    }

    final list = result.toList()
      ..sort(
      (a, b) =>
        b.transactionDate.compareTo(
          a.transactionDate,
        ),
    );



    final limit = filter.limit.count;

    // if (limit != null) {
    //   result = result.take(limit);
    // }

    // return result.toList();

    if (limit != null) {
      return list.take(limit).toList();
    }

    return list;
  });
});
