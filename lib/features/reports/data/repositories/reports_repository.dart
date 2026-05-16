import 'package:isar/isar.dart';

import '../../../../shared/models/category_model.dart';
import '../../../../shared/models/transaction_model.dart';
import '../../domain/models/category_expense_model.dart';
import '../../domain/models/monthly_summary_model.dart';

class ReportsRepository {

  final Isar isar;

  ReportsRepository(this.isar);

  Future<MonthlySummaryModel>
      getMonthlySummary(
    DateTime month,
  ) async {

    final start =
        DateTime(month.year, month.month, 1);

    final end =
        DateTime(month.year, month.month + 1, 0);

    final transactions =
        await isar.transactionModels
            .filter()
            .transactionDateBetween(
              start,
              end,
            )
            .findAll();

    int income = 0;
    int expense = 0;

    for (final transaction
        in transactions) {

      if (transaction.type ==
          'income') {
        income += transaction.amount;
      } else {
        expense += transaction.amount;
      }
    }

    return MonthlySummaryModel(
      income: income,
      expense: expense,
    );
  }

  Future<List<CategoryExpenseModel>>
      getCategoryExpenses(
    DateTime month,
  ) async {

    final start =
        DateTime(month.year, month.month, 1);

    final end =
        DateTime(month.year, month.month + 1, 0);

    final transactions =
        await isar.transactionModels
            .filter()
            .typeEqualTo('expense')
            .transactionDateBetween(
              start,
              end,
            )
            .findAll();

    final categories =
        await isar.categoryModels
            .where()
            .findAll();

    final Map<int, int> totals = {};

    for (final transaction
        in transactions) {

      totals.update(
        transaction.categoryId,
        (value) =>
            value + transaction.amount,
        ifAbsent: () =>
            transaction.amount,
      );
    }

    final List<CategoryExpenseModel>
        result = [];

    for (final entry in totals.entries) {

      final category = categories
          .firstWhere(
        (e) => e.id == entry.key,
        orElse: () =>
            CategoryModel()
              ..name = 'Unknown',
      );

      result.add(
        CategoryExpenseModel(
          category: category.name,
          amount: entry.value,
        ),
      );
    }

    return result;
  }
}