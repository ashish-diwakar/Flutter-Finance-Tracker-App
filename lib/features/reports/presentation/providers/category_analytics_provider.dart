import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/models/category_expense_model.dart';
import 'reports_repository_provider.dart';

final categoryAnalyticsProvider =
    FutureProvider.family<
        List<CategoryExpenseModel>,
        DateTime>((ref, month) async {

  final repository =
      await ref.watch(
        reportsRepositoryProvider.future,
      );

  return repository.getCategoryExpenses(
    month,
  );
});