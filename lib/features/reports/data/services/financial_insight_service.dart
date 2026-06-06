import 'package:isar/isar.dart';

import '../../../../shared/models/category_model.dart';
import '../../../../shared/models/transaction_model.dart';

import '../../domain/models/financial_insight_model.dart';

class FinancialInsightService {

  final Isar isar;

  FinancialInsightService(
    this.isar,
  );

  Future<List<
      FinancialInsightModel>>
      generateInsights()
  async {

    final now =
        DateTime.now();

    final currentMonthStart =
        DateTime(
      now.year,
      now.month,
      1,
    );

    final previousMonthStart =
        DateTime(
      now.year,
      now.month - 1,
      1,
    );

    // final previousMonthEnd =
    //     DateTime(
    //   now.year,
    //   now.month,
    //   0,
    // );

    // final currentTransactions =
    //     await isar
    //         .transactionModels
    //         .filter()
    //         .transactionDateGreaterThan(
    //           currentMonthStart,
    //         )
    //         .isDeletedEqualTo(
    //           false,
    //         )
    //         .findAll();

    final currentMonthEnd =
    DateTime(
      now.year,
      now.month + 1,
      1,
    );

    final currentTransactions =
        await isar
            .transactionModels
            .filter()
            .isDeletedEqualTo(
              false,
            )
            .transactionDateBetween(
              currentMonthStart,
              currentMonthEnd,
              includeLower: true,
              includeUpper: false,
            )
            .findAll();

    final previousTransactions =
        await isar
            .transactionModels
            .filter()
            .transactionDateBetween(
              previousMonthStart,
              //previousMonthEnd,
              currentMonthStart,
              includeLower: true,
              includeUpper: true,
            )
            .isDeletedEqualTo(
              false,
            )
            .findAll();

    final insights =
        <FinancialInsightModel>[];

    double currentExpense = 0;
    double previousExpense = 0;

    for (final t
        in currentTransactions) {

      if (t.type ==
          'expense') {

        currentExpense +=
            t.amount / 100;
      }
    }

    for (final t
        in previousTransactions) {

      if (t.type ==
          'expense') {

        previousExpense +=
            t.amount / 100;
      }
    }

    // =========================================
    // EXPENSE TREND
    // =========================================

    if (previousExpense > 0) {

      final change =
          ((currentExpense -
                          previousExpense) /
                      previousExpense) *
                  100;

      if (change > 15) {

        insights.add(

          FinancialInsightModel(

            title:
                'Spending Increased',

            description:
                'Your expenses increased by ${change.toStringAsFixed(0)}% compared to last month.',

            type: 'warning',
          ),
        );
      }

      if (change < -10) {

        insights.add(

          FinancialInsightModel(

            title:
                'Improved Savings',

            description:
                'Great work! Your spending reduced by ${change.abs().toStringAsFixed(0)}% this month.',

            type: 'success',
          ),
        );
      }
    }

    // =========================================
    // CATEGORY ANALYSIS
    // =========================================

    final Map<int, double>
        categoryTotals = {};

    for (final t
        in currentTransactions) {

      if (t.type !=
          'expense') {

        continue;
      }

      categoryTotals[
              t.categoryId] =
          (categoryTotals[
                      t.categoryId] ??
                  0) +
              (t.amount / 100);
    }

    if (categoryTotals
        .isNotEmpty) {

      final top =
          categoryTotals.entries
              .reduce(
        (a, b) =>
            a.value > b.value
                ? a
                : b,
      );

      final category =
          await isar
              .categoryModels
              .get(
            top.key,
          );

      if (category != null &&
          !category.isDeleted) {

        insights.add(

          FinancialInsightModel(

            title:
                'Highest Spending Category',

            description:
                '${category.name} accounted for your highest spending this month.',

            type: 'info',
          ),
        );
      }
    }

    // =========================================
    // LOW ACTIVITY
    // =========================================

    if (currentTransactions
            .length <
        5) {

      insights.add(

        FinancialInsightModel(

          title:
              'Track More Transactions',

          description:
              'Add more transactions to improve financial insights accuracy.',

          type: 'tip',
        ),
      );
    }

    return insights;
  }
}