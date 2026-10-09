import 'package:isar_community/isar.dart';

import '../../../../shared/models/category_model.dart';
import '../../../../shared/models/recurring_transaction_model.dart';
import '../../../../shared/models/transaction_model.dart';

import '../../domain/models/recurring_analytics_model.dart';

class RecurringAnalyticsService {
  final Isar isar;

  RecurringAnalyticsService(
    this.isar,
  );

  Future<RecurringAnalyticsModel>
      calculateAnalytics() async {
    // =========================================
    // LOAD ACTIVE RECURRING TRANSACTIONS
    // =========================================

    final recurring =
        await isar
            .recurringTransactionModels
            .filter()
            .isActiveEqualTo(true)
            .and()
            .isDeletedEqualTo(false)
            .findAll();

    // Monthly Commitments represents
    // recurring EXPENSES only.
    final expenseRecurring =
        recurring
            .where(
              (r) =>
                  r.type == 'expense',
            )
            .toList();

    // =========================================
    // CURRENT MONTH INCOME
    // =========================================

    final now = DateTime.now();

    final startOfMonth = DateTime(
      now.year,
      now.month,
      1,
    );

    final startOfNextMonth = DateTime(
      now.year,
      now.month + 1,
      1,
    );

    final incomeTransactions =
        await isar
            .transactionModels
            .filter()
            .typeEqualTo('income')
            .isDeletedEqualTo(false)
            .transactionDateBetween(
              startOfMonth,
              startOfNextMonth,
              includeLower: true,
              includeUpper: false,
            )
            .findAll();

    final totalIncome =
        incomeTransactions.fold<double>(
      0.0,
      (sum, transaction) =>
          sum +
          transaction.amount / 100,
    );

    // =========================================
    // LOAD CATEGORIES
    // =========================================

    final categories =
        await isar
            .categoryModels
            .filter()
            .isDeletedEqualTo(false)
            .findAll();

    final Map<String, String>
        categoryMap = {
      for (final category
          in categories)
        category.uuid:
            category.name,
    };

    // =========================================
    // MONTHLY RECURRING EXPENSE
    // =========================================

    double monthlyRecurring = 0;

    final Map<String, double>
        categoryTotals = {};

    for (final recurring
        in expenseRecurring) {
      double amount =
          recurring.amount / 100;

      // =====================================
      // NORMALIZE TO MONTHLY
      // =====================================

      switch (recurring.frequency) {
        case 'daily':
          amount *=
              30 /
              recurring.interval;
          break;

        case 'weekly':
          amount *=
              4.345 /
              recurring.interval;
          break;

        case 'monthly':
          amount /=
              recurring.interval;
          break;

        case 'yearly':
          amount /=
              12 *
              recurring.interval;
          break;
      }

      monthlyRecurring += amount;

      // =====================================
      // CATEGORY NAME LOOKUP
      // =====================================

      final categoryName =
          categoryMap[
                  recurring.categoryId] ??
              'Other';

      categoryTotals.update(
        categoryName,
        (value) =>
            value + amount,
        ifAbsent: () => amount,
      );
    }

    // =========================================
    // YEARLY RECURRING EXPENSE
    // =========================================

    final yearlyRecurring =
        monthlyRecurring * 12;

    // =========================================
    // RECURRING EXPENSE / MONTHLY INCOME RATIO
    // =========================================

    // final recurringIncomeRatio =
    //     totalIncome <= 0
    //         ? 0.0
    //         : ((monthlyRecurring /
    //                     totalIncome) *
    //                 100)
    //             .clamp(
    //               0.0,
    //               100.0,
    //             )
    //             .toDouble();
    final recurringIncomeRatio =
    totalIncome <= 0
        ? 0.0
        : (monthlyRecurring /
                totalIncome) *
            100;
            
    // =========================================
    // TOP RECURRING EXPENSE CATEGORY
    // =========================================

    String? topCategory;

    if (categoryTotals.isNotEmpty) {
      topCategory =
          categoryTotals.entries
              .reduce(
        (a, b) =>
            a.value > b.value
                ? a
                : b,
      ).key;
    }

    // =========================================
    // RESULT
    // =========================================

    return RecurringAnalyticsModel(
      monthlyRecurringExpense:
          monthlyRecurring,
      yearlyRecurringExpense:
          yearlyRecurring,
      recurringIncomeRatio:
          recurringIncomeRatio,
      activeRecurringCount:
          expenseRecurring.length,
      topRecurringCategory:
          topCategory,
    );
  }
}