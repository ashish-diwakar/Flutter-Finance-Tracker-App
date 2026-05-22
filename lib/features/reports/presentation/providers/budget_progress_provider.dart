import 'package:isar/isar.dart';
import 'package:finance_tracker/shared/providers/database_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:finance_tracker/shared/models/transaction_model.dart';
import 'package:finance_tracker/shared/models/category_model.dart';

import '../../domain/models/budget_progress_data.dart';

final budgetProgressProvider =
    FutureProvider<
        List<BudgetProgressData>>(
  (ref) async {

    final isar =
        await ref.read(
      isarProvider.future,
    );

    final transactions =
        await isar.transactionModels
            .filter()
            .typeEqualTo('expense')
            .isDeletedEqualTo(false)
            .findAll();

    final categories =
        await isar.categoryModels
            .where()
            .findAll();

    final Map<String, double>
        totals = {};

    for (final transaction
        in transactions) {

      final category =
          categories.firstWhere(
        (c) =>
            c.id ==
            transaction.categoryId,
      );

      final amount =
          transaction.amount / 100;

      totals.update(
        category.name,
        (value) =>
            value + amount,

        ifAbsent: () => amount,
      );
    }

    return totals.entries.map((e) {

      final simulatedBudget =
          e.value * 1.2;

      return BudgetProgressData(

        category: e.key,

        spent: e.value,

        budget:
            simulatedBudget,
      );
    }).toList();
  },
);