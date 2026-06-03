import 'package:isar/isar.dart';
import 'package:finance_tracker/shared/providers/database_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:finance_tracker/shared/models/transaction_model.dart';

import '../../domain/models/budget_progress_data.dart';
import '../../../categories/presentation/providers/category_repository_provider.dart';

final budgetProgressProvider =
    FutureProvider.family<
        List<BudgetProgressData>,
        DateTime>(
  (ref, month) async {

    final isar =
        await ref.read(
      isarProvider.future,
    );

    final repository =
        await ref.read(
      categoryRepositoryProvider.future,
    );

    final startOfMonth =
        DateTime(
      month.year,
      month.month,
      1,
    );

    final startOfNextMonth =
        month.month == 12

            ? DateTime(
                month.year + 1,
                1,
                1,
              )

            : DateTime(
                month.year,
                month.month + 1,
                1,
              );

    final expenseTransactions =
        await isar
            .transactionModels
            .filter()
            .typeEqualTo(
              'expense',
            )
            .isDeletedEqualTo(
              false,
            )
            .transactionDateBetween(
              startOfMonth,
              startOfNextMonth,
              includeLower: true,
              includeUpper: false,
            )
            .findAll();

    final incomeTransactions =
        await isar
            .transactionModels
            .filter()
            .typeEqualTo(
              'income',
            )
            .isDeletedEqualTo(
              false,
            )
            .transactionDateBetween(
              startOfMonth,
              startOfNextMonth,
              includeLower: true,
              includeUpper: false,
            )
            .findAll();

    final categories =
        await repository
            .getAllCategories();

    final Map<String, double>
        totals = {};

    final totalIncome =
        incomeTransactions.fold<double>(
      0.0,
      (sum, transaction) =>
          sum +
          transaction.amount,
    );

    for (final transaction
        in expenseTransactions) {

      final matchingCategories =
          categories.where(
        (c) =>
            c.id ==
            transaction.categoryId,
      );

      if (matchingCategories
          .isEmpty) {

        print(
          'No category found for transaction with categoryId: ${transaction.categoryId}',
        );

        continue;
      }

      final category =
          matchingCategories.first;

      final amount =
          transaction.amount / 100;

      totals.update(
        category.name,
        (value) =>
            value + amount,
        ifAbsent: () => amount,
      );
    }

    final result =
        totals.entries.map((e) {

      final category =
          categories.firstWhere(
        (c) =>
            c.name == e.key,
      );

      final budget =
          (category.monthlyBudget ??
                  totalIncome) /
              100;

      return BudgetProgressData(

        category:
            e.key,

        spent:
            e.value,

        budget:
            budget,
      );

    }).toList();

    return result;
  },
);