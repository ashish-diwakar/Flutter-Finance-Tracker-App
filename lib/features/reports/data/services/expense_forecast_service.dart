import 'package:isar/isar.dart';

import '../../../../shared/models/transaction_model.dart';

import '../../domain/models/expense_forecast_model.dart';

class ExpenseForecastService {

  final Isar isar;

  ExpenseForecastService(
    this.isar,
  );

  Future<ExpenseForecastModel>
      generateForecast()
  async {

    final now =
        DateTime.now();

    final monthStart =
        DateTime(
      now.year,
      now.month,
      1,
    );

    final transactions =
        await isar
            .transactionModels
            .filter()
            .typeEqualTo(
              'expense',
            )
            .transactionDateGreaterThan(
              monthStart,
            )
            .isDeletedEqualTo(
              false,
            )
            .findAll();

    double expense = 0;

    for (final t
        in transactions) {

      expense +=
          t.amount / 100;
    }

    final daysPassed =
        now.day;

    final totalDays =
        DateTime(
          now.year,
          now.month + 1,
          0,
        ).day;

    final dailyAverage =
        expense / daysPassed;

    final projected =
        dailyAverage *
            totalDays;

    return ExpenseForecastModel(

      currentExpense:
          expense,

      projectedExpense:
          projected,

      dailyAverage:
          dailyAverage,

      daysPassed:
          daysPassed,

      totalDays:
          totalDays,
    );
  }
}