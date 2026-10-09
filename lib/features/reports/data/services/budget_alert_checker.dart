import 'package:isar_community/isar.dart';

import '../../../../shared/models/category_model.dart';
import '../../../../shared/models/transaction_model.dart';

import '../../domain/models/budget_alert_model.dart';

enum FinancialTargetType {
  expenseBudget,
  incomeTarget,
}

class BudgetAlertChecker {
  final Isar isar;

  BudgetAlertChecker(
    this.isar,
  );

  Future<List<BudgetAlertModel>>
      checkAlerts({
    bool includeSafe = false,
    FinancialTargetType targetType =
        FinancialTargetType.expenseBudget,
    DateTime? month,
  }) async {
    final selectedMonth =
        month ?? DateTime.now();

    final startOfMonth = DateTime(
      selectedMonth.year,
      selectedMonth.month,
      1,
    );

    final startOfNextMonth = DateTime(
      selectedMonth.year,
      selectedMonth.month + 1,
      1,
    );

    // =========================================
    // TARGET SEMANTICS
    // =========================================

    final categoryType =
        targetType ==
                FinancialTargetType.expenseBudget
            ? 'expense'
            : 'income';

    final transactionType =
        targetType ==
                FinancialTargetType.expenseBudget
            ? 'expense'
            : 'income';

    // =========================================
    // LOAD CURRENT-MONTH TRANSACTIONS
    // =========================================

    final transactions =
        await isar
            .transactionModels
            .filter()
            .typeEqualTo(
              transactionType,
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

    // =========================================
    // LOAD CATEGORIES
    // =========================================

    final categories =
        await isar
            .categoryModels
            .filter()
            .isDeletedEqualTo(
              false,
            )
            .findAll();

    // =========================================
    // ACTUAL AMOUNTS BY CATEGORY
    // =========================================

    final Map<String, double>
        actualAmounts = {};

    for (final transaction
        in transactions) {
      final categoryId =
          transaction.categoryId;

      if (categoryId == null ||
          categoryId.isEmpty) {
        continue;
      }

      actualAmounts.update(
        categoryId,
        (value) =>
            value +
            (transaction.amount / 100),
        ifAbsent: () =>
            transaction.amount / 100,
      );
    }

    // =========================================
    // BUILD TARGET RESULTS
    // =========================================

    final List<BudgetAlertModel>
        alerts = [];

    for (final category
        in categories) {
      // Only categories relevant
      // to the selected target type.
      if (category.type !=
          categoryType) {
        continue;
      }

      final monthlyTarget =
          category.monthlyBudget;

      if (monthlyTarget == null ||
          monthlyTarget <= 0) {
        continue;
      }

      final target =
          monthlyTarget / 100;

      final actual =
          actualAmounts[
                  category.uuid] ??
              0.0;

      final percentage =
          actual / target;

      BudgetAlertType type;

      if (targetType ==
          FinancialTargetType
              .expenseBudget) {
        // =====================================
        // EXPENSE BUDGET
        // Higher usage = worse
        // =====================================

        if (percentage >= 1) {
          type =
              BudgetAlertType.exceeded;
        } else if (percentage >=
            0.8) {
          type =
              BudgetAlertType.warning;
        } else {
          if (!includeSafe) {
            continue;
          }

          type =
              BudgetAlertType.safe;
        }
      } else {
        // =====================================
        // INCOME TARGET
        // Higher progress = better
        // =====================================

        if (percentage >= 1) {
          type =
              BudgetAlertType.safe;
        } else if (percentage >=
            0.8) {
          type =
              BudgetAlertType.warning;
        } else {
          // Reuse the existing severe state.
          // UI will later display this as
          // "Behind target", not
          // "Budget exceeded".
          type =
              BudgetAlertType.exceeded;
        }
      }

      alerts.add(
        BudgetAlertModel(
          category:
              category.name,

          // For expense mode:
          //   spent = amount spent
          //
          // For income mode:
          //   spent = amount received
          spent: actual,

          // For expense mode:
          //   budget = monthly budget
          //
          // For income mode:
          //   budget = monthly income target
          budget: target,

          percentage:
              percentage,

          type: type,
        ),
      );
    }

    // =========================================
    // SORT
    // =========================================

    if (targetType ==
        FinancialTargetType
            .expenseBudget) {
      // Most-used budgets first.
      alerts.sort(
        (a, b) =>
            b.percentage.compareTo(
          a.percentage,
        ),
      );
    } else {
      // Income targets furthest behind first.
      alerts.sort(
        (a, b) =>
            a.percentage.compareTo(
          b.percentage,
        ),
      );
    }

    return alerts;
  }
}