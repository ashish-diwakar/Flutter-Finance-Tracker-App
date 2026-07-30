import '../../../dashboard/presentation/providers/transaction_filter_provider.dart';

extension TransactionFilterExtension
    on TransactionFilter {

  int get activeFilterCount {

    var count = 0;

    if (searchText.isNotEmpty) count++;

    if (categoryId != null) count++;

    if (accountId != null) count++;

    if (fromDate != null) count++;

    if (toDate != null) count++;

    if (type != TransactionTypeFilter.all) count++;

    if (limit != TransactionLimit.last10) count++;

    return count;
  }
}