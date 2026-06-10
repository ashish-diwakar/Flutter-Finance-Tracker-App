import 'package:isar_community/isar.dart';

import '../../../../shared/models/category_model.dart';
import '../../../../shared/models/transaction_model.dart';

import '../../domain/models/financial_health_model.dart';

class FinancialHealthService {

  final Isar isar;

  FinancialHealthService(
    this.isar,
  );

  Future<
      FinancialHealthModel>
      calculateHealth()
  async {
    final now = DateTime.now();

    final startOfMonth =
        DateTime(
          now.year,
          now.month,
          1,
        );

    final startOfNextMonth =
        now.month == 12

            ? DateTime(
                now.year + 1,
                1,
                1,
              )

            : DateTime(
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
              startOfMonth,
              startOfNextMonth,
              includeLower: true,
              includeUpper: false,
            )
            .findAll();

    double income = 0;
    double expense = 0;

    for (final t
        in transactions) {

      final amount =
          t.amount / 100;

      if (t.type ==
          'income') {

        income += amount;

      } else {

        expense += amount;
      }
    }

    final balance =
        income - expense;

    // =========================================
    // SAVINGS RATE
    // =========================================

    final savingsRate =

        income <= 0

            ? 0

            : ((balance / income) *
                    100)
                .clamp(
              0,
              100,
            );

    // =========================================
    // EXPENSE RATIO
    // =========================================

    final expenseRatio =

        income <= 0

            ? 100

            : ((expense / income) *
                    100)
                .clamp(
              0,
              100,
            );

    // =========================================
    // BUDGET USAGE
    // =========================================

    final categories =
    await isar
        .categoryModels
        .filter()
        .isDeletedEqualTo(
          false,
        )
        .findAll();

    double totalBudget = 0;

    for (final c
        in categories) {

      if (c.monthlyBudget !=
          null) {

        totalBudget +=
            c.monthlyBudget! / 100;
      }
    }

    final budgetUsage =

        totalBudget <= 0

            ? 0

            : ((expense /
                            totalBudget) *
                        100)
                    .clamp(
                  0,
                  100,
                );

    // =========================================
    // SCORING
    // =========================================

    double score = 0;

    // Savings score (40)

    score +=
        (savingsRate * 0.4);

    // Expense ratio (30)

    score +=
        ((100 -
                    expenseRatio) *
                0.3);

    // Budget discipline (30)

    // score +=
    //     ((100 -
    //                 budgetUsage) *
    //             0.3);
    if (totalBudget > 0) {

      score +=
          ((100 - budgetUsage) * 0.3);

    } else {

      // Neutral score when no budgets exist
      score += 15;
    }

    score =
        score.clamp(
      0,
      100,
    );

    // =========================================
    // LABEL
    // =========================================

    String label;
    String description;

    if (score >= 85) {

      label =
          'Excellent';

      description =
          'Your finances are in excellent condition.';

    } else if (score >=
        70) {

      label =
          'Good';

      description =
          'You are maintaining healthy financial habits.';

    } else if (score >=
        55) {

      label =
          'Moderate';

      description =
          'Your finances are stable but need improvement.';

    } else if (score >=
        40) {

      label =
          'Risky';

      description =
          'Your spending patterns need attention.';

    } else {

      label =
          'Critical';

      description =
          'Immediate financial improvements are recommended.';
    }

    return FinancialHealthModel(

      score: score,

      label: label,

      description:
          description,

      savingsRate:
          savingsRate.toDouble(),

      expenseRatio:
          expenseRatio.toDouble(),

      budgetUsage:
          budgetUsage.toDouble(),
    );
  }
}