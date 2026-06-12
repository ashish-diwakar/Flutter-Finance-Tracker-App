import 'package:isar_community/isar.dart';

import '../../../../shared/models/category_model.dart';
import '../../../../shared/models/recurring_transaction_model.dart';
import '../../../../shared/models/transaction_model.dart';

import '../../domain/models/finance_insight_model.dart';

class DashboardInsightsService {

  final Isar isar;

  DashboardInsightsService(
    this.isar,
  );

  Future<List<
      FinanceInsightModel>>
      generateInsights()
  async {

    final now =
        DateTime.now().toUtc();

    final monthStart =
        DateTime(
      now.year,
      now.month,
      1,
    );

    final startOfNextMonth =
        DateTime(
          now.year,
          now.month + 1,
          1,
        );

    final transactions =
        await isar
            .transactionModels
            .filter()
            .isDeletedEqualTo(
              false,
            )
            .transactionDateBetween(
              monthStart,
              startOfNextMonth,
              includeLower: true,
              includeUpper: false,
            )
            .findAll();
    // final transactions =
    //     await isar
    //         .transactionModels
    //         .filter()
    //         .transactionDateGreaterThan(
    //           monthStart,
    //         )
    //         .isDeletedEqualTo(
    //           false,
    //         )
    //         .findAll();

    final categories =
        await isar
            .categoryModels
            .filter()
            .isDeletedEqualTo(
              false,
            )
            .findAll();

    final recurring =
        await isar
            .recurringTransactionModels
            .filter()
            .isDeletedEqualTo(
              false,
            )
            .isActiveEqualTo(
              true,
            )
            .findAll();

    final List<
        FinanceInsightModel>
        insights = [];

    // =====================================
    // TOTAL INCOME / EXPENSE
    // =====================================

    double income = 0;

    double expense = 0;

    for (final transaction
        in transactions) {

      final amount =
          transaction.amount / 100;

      if (transaction.type ==
          'income') {

        income += amount;

      } else {

        expense += amount;
      }
    }

    final savings =
        income - expense;

    if (savings > 0) {

      insights.add(

        FinanceInsightModel(

          title:
              'Savings This Month',

          description:
              'You saved ₹${savings.toStringAsFixed(0)} this month.',

          type:
              FinanceInsightType
                  .success,
        ),
      );
    }
    else {
      insights.add(

        FinanceInsightModel(

          title:
              'Overspending Alert',

          description:
              'You spent ₹${(-savings).toStringAsFixed(0)} more than you earned this month.',

          type:
              FinanceInsightType
                  .warning,
        ),
      );
    }

    // =====================================
    // HIGHEST EXPENSE CATEGORY
    // =====================================

    final Map<String, double>
        categorySpending = {};

    for (final transaction
        in transactions) {

      if (transaction.type !=
          'expense') {

        continue;
      }

      categorySpending.update(

        transaction.categoryId,

        (value) =>
            value +
            (transaction.amount /
                100),

        ifAbsent: () =>
            transaction.amount /
            100,
      );
    }

    if (categorySpending
        .isNotEmpty) {

      final highest =
          categorySpending.entries
              .reduce(
        (a, b) {

          return a.value >
                  b.value

              ? a

              : b;
        },
      );

      // final category =
      //     categories.firstWhere(
      //   (c) =>
      //       c.id ==
      //       highest.key,
      // );

      final matchingCategories =
          categories.where(
        (c) =>
            c.id ==
            highest.key,
      );

      if (matchingCategories.isNotEmpty) {

        final category = matchingCategories.first;
          
        insights.add(

          FinanceInsightModel(

            title:
                'Highest Expense',

            description:
                '${category.name} consumed ₹${highest.value.toStringAsFixed(0)}.',

            type:
                FinanceInsightType
                    .warning,
          ),
        );
      }

    }

    // =====================================
    // RECURRING PAYMENTS
    // =====================================

    final upcoming =
        recurring.where(
      (r) {

        // return r.nextRunDate
        //     .difference(now)
        //     .inDays <= 7;

        return
          r.nextRunDate.isAfter(now) &&
          r.nextRunDate
                  .difference(now)
                  .inDays <=
              7;
      },
    ).length;

    if (upcoming > 0) {

      insights.add(

        FinanceInsightModel(

          title:
              'Upcoming Recurring',

          description:
              '$upcoming recurring transactions scheduled within 7 days.',

          type:
              FinanceInsightType
                  .info,
        ),
      );
    }

    return insights;
  }
}