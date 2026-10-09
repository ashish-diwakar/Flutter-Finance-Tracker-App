import 'package:finance_tracker/core/services/logger_service.dart';
import 'package:isar_community/isar.dart';
import 'package:finance_tracker/shared/providers/database_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:finance_tracker/shared/models/transaction_model.dart';

import '../../../../shared/models/category_model.dart';
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

    // final incomeTransactions =
    //     await isar
    //         .transactionModels
    //         .filter()
    //         .typeEqualTo(
    //           'income',
    //         )
    //         .isDeletedEqualTo(
    //           false,
    //         )
    //         .transactionDateBetween(
    //           startOfMonth,
    //           startOfNextMonth,
    //           includeLower: true,
    //           includeUpper: false,
    //         )
    //         .findAll();

    final categories =
        await repository
            .getAllCategoriesIncludingDeleted();

    final categoryMap = <String, CategoryModel>{
      for (final category in categories)
        category.uuid: category,
    };

    final Map<String, double> totals = {};

    // final totalIncome =
    //     incomeTransactions.fold<double>(
    //   0.0,
    //   (sum, transaction) =>
    //       sum +
    //       transaction.amount,
    // );




    // for (final transaction in expenseTransactions) {
    //   final categoryId = transaction.categoryId;

    //   if (categoryId == null ||
    //       categoryId.isEmpty) {
    //     LoggerService.error(
    //       'Expense transaction has no categoryId.',
    //     );
    //     continue;
    //   }

    //   final category =
    //       categoryMap[categoryId];

    //   if (category == null) {
    //     LoggerService.error(
    //       'No category found for transaction with categoryId: '
    //       '$categoryId',
    //     );
    //     continue;
    //   }

    //   final amount =
    //       transaction.amount / 100;

    //   totals.update(
    //     categoryId,
    //     (value) => value + amount,
    //     ifAbsent: () => amount,
    //   );
    // }

    for (final transaction
        in expenseTransactions) {
      final categoryId =
          transaction.categoryId;

      if (categoryId == null ||
          categoryId.isEmpty) {
        LoggerService.error(
          'Expense transaction has no categoryId.',
        );
        continue;
      }

      final category =
          categoryMap[categoryId];

      if (category == null) {
        LoggerService.error(
          'No category found for transaction with categoryId: '
          '$categoryId',
        );
        continue;
      }

      final amount =
          transaction.amount / 100;

      totals.update(
        categoryId,
        (value) => value + amount,
        ifAbsent: () => amount,
      );
    }

    // final result =
    //     totals.entries.map((entry) {
    //   final category =
    //       categoryMap[entry.key]!;

    //   final budget =
    //       (category.monthlyBudget ??
    //               totalIncome) /
    //           100;

    //   return BudgetProgressData(
    //     category: category.name,
    //     spent: entry.value,
    //     budget: budget,
    //   );
    // }).toList();

    // return result;
    final List<BudgetProgressData> result = [];

    for (final category in categories) {
      // Budget Performance applies only
      // to expense categories.
      if (category.type != 'expense') {
        continue;
      }


      final monthlyBudget =
          category.monthlyBudget;

      if (monthlyBudget == null ||
          monthlyBudget <= 0) {
        continue;
      }

      final spent =
          totals[category.uuid] ?? 0.0;

      // Preserve a deleted category in historical
      // reporting only when it actually had spending
      // during the selected month.
      if (category.isDeleted &&
          spent == 0) {
        continue;
      }

      result.add(
        BudgetProgressData(
          category: category.name,
          spent: spent,
          budget: monthlyBudget / 100,
        ),
      );
    }

    return result;
  },
);