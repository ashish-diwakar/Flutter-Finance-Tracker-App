import 'package:isar/isar.dart';

import '../../../../shared/models/category_model.dart';
import '../../../../shared/models/recurring_transaction_model.dart';
import '../../../../shared/models/transaction_model.dart';

import '../../domain/models/recurring_analytics_model.dart';

class RecurringAnalyticsService {

  final Isar isar;

  RecurringAnalyticsService(
    this.isar,
  );

  Future<
      RecurringAnalyticsModel>
      calculateAnalytics()
  async {

    // =========================================
    // LOAD RECURRING
    // =========================================

    final recurring =

        await isar
            .recurringTransactionModels
            .filter()
            .isActiveEqualTo(
              true,
            )
            .and()
            .isDeletedEqualTo(
              false,
            )
            .findAll();

    // =========================================
    // LOAD TRANSACTIONS
    // =========================================

    final transactions =

        await isar
            .transactionModels
            .filter()
            .isDeletedEqualTo(
              false,
            )
            .findAll();

    // =========================================
    // LOAD CATEGORIES
    // =========================================

    final categories =
        await isar
            .categoryModels
            .where()
            .findAll();

    final Map<
            int,
            String>
        categoryMap = {

      for (final c
          in categories)

        c.id: c.name,
    };

    // =========================================
    // TOTAL INCOME
    // =========================================

    double totalIncome = 0;

    for (final t
        in transactions) {

      if (t.type ==
          'income') {

        totalIncome +=
            t.amount / 100;
      }
    }

    // =========================================
    // MONTHLY RECURRING
    // =========================================

    double monthlyRecurring =
        0;

    final Map<
            String,
            double>
        categoryTotals = {};

    for (final r
        in recurring) {

      double amount =
          r.amount / 100;

      // =====================================
      // NORMALIZE TO MONTHLY
      // =====================================

      switch (
          r.frequency) {

        case 'daily':

          amount *= 30;
          break;

        case 'weekly':

          amount *= 4;
          break;

        case 'monthly':

          break;

        case 'yearly':

          amount /= 12;
          break;
      }

      monthlyRecurring +=
          amount;

      // =====================================
      // CATEGORY NAME LOOKUP
      // =====================================

      final categoryName =

          categoryMap[
                  r.categoryId] ??
              'Other';

      categoryTotals[
          categoryName] =

          (categoryTotals[
                      categoryName] ??
                  0) +
              amount;
    }

    // =========================================
    // YEARLY RECURRING
    // =========================================

    final yearlyRecurring =
        monthlyRecurring * 12;

    // =========================================
    // RECURRING INCOME RATIO
    // =========================================

    final recurringIncomeRatio =

        totalIncome <= 0

            ? 0

            : ((monthlyRecurring /
                            totalIncome) *
                        100)
                    .clamp(
                  0,
                  100,
                );

    // =========================================
    // TOP CATEGORY
    // =========================================

    String? topCategory;

    if (categoryTotals
        .isNotEmpty) {

      topCategory =
          categoryTotals.entries

              .reduce(

        (a, b) {

          return a.value >
                  b.value

              ? a

              : b;
        },
      ).key;
    }

    return RecurringAnalyticsModel(

      monthlyRecurringExpense:
          monthlyRecurring,

      yearlyRecurringExpense:
          yearlyRecurring,

      recurringIncomeRatio:
          recurringIncomeRatio.toDouble(),

      activeRecurringCount:
          recurring.length,

      topRecurringCategory:
          topCategory,
    );
  }
}