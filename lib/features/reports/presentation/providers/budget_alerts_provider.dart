
import 'package:isar/isar.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:finance_tracker/shared/models/transaction_model.dart';
import 'package:finance_tracker/shared/models/category_model.dart';

import '../../../../shared/providers/database_provider.dart';
import '../../domain/models/budget_alert_model.dart';

final budgetAlertsProvider =
    FutureProvider<
        List<BudgetAlertModel>>(
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
            .filter()
            .isDeletedEqualTo(false)
            .findAll();

    final Map<int, double>
        spendingMap = {};

    for (final transaction
        in transactions) {

      final amount =
          transaction.amount / 100;

      spendingMap.update(

        transaction.categoryId,

        (value) =>
            value + amount,

        ifAbsent: () => amount,
      );
    }

    final List<BudgetAlertModel>
        alerts = [];

    for (final category
        in categories) {

      final budget =
          (category.monthlyBudget ??
                  0) /
              100;

      if (budget <= 0) {
        continue;
      }

      final spent =
          spendingMap[
                  category.id] ??
              0;

      final percentage =
          spent / budget;

      BudgetAlertType type;

      if (percentage >= 1) {

        type =
            BudgetAlertType
                .exceeded;

      } else if (percentage >=
          0.8) {

        type =
            BudgetAlertType
                .warning;

      } else {

        type =
            BudgetAlertType.safe;
      }

      alerts.add(

        BudgetAlertModel(

          category:
              category.name,

          spent: spent,

          budget: budget,

          percentage:
              percentage,

          type: type,
        ),
      );
    }

    alerts.sort(
      (a, b) =>
          b.percentage
              .compareTo(
        a.percentage,
      ),
    );

    return alerts;
  },
);