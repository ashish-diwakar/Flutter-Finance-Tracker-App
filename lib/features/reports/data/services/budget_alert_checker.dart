import 'package:isar_community/isar.dart';

import '../../../../shared/models/category_model.dart';
import '../../../../shared/models/transaction_model.dart';

import '../../domain/models/budget_alert_model.dart';

class BudgetAlertChecker {

  final Isar isar;

  BudgetAlertChecker(
    this.isar,
  );

  Future<List<BudgetAlertModel>>
    checkAlerts({
      bool includeSafe = false,
  })
  async {

    final now = DateTime.now().toUtc();
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

    final categories =
        await isar
            .categoryModels
            .filter()
            .isDeletedEqualTo(
              false,
            )
            .findAll();

    final Map<String, double>
        spending = {};

    for (final transaction
        in transactions) {

      spending.update(

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

    final List<
        BudgetAlertModel> alerts = [];

    for (final category
        in categories) {

      if (category
              .monthlyBudget ==
          null) {

        continue;
      }

      final budget =
          category.monthlyBudget! /
              100;

      if (budget <= 0) {
        continue;
      }

      final spent =
          spending[
                  category.uuid] ??
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
        if(includeSafe) {
          type =
              BudgetAlertType
                  .safe;
        } else {
          continue;
        }
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
  }
}