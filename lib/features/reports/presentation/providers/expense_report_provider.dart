import 'package:finance_tracker/shared/models/category_model.dart';
import 'package:finance_tracker/shared/models/transaction_model.dart';
import 'package:finance_tracker/shared/providers/database_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';

import '../../domain/models/category_expense_model_2.dart';

final expenseReportProvider =
    FutureProvider<
        List<CategoryExpense2Model>>(
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
        categoryTotals = {};

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

      categoryTotals.update(
        category.name,
        (value) =>
            value + amount,

        ifAbsent: () => amount,
      );
    }

    return categoryTotals.entries
        .map(
          (e) =>
              CategoryExpense2Model(
            category: e.key,
            amount: e.value,
          ),
        )
        .toList();
  },
);