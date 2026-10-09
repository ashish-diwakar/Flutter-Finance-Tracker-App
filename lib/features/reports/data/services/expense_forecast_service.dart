import 'package:isar_community/isar.dart';

import '../../../../shared/models/transaction_model.dart';

import '../../domain/models/expense_forecast_model.dart';

class ExpenseForecastService {

  final Isar isar;

  ExpenseForecastService(
    this.isar,
  );

  Future<ExpenseForecastModel>
      generateForecast(
        DateTime? month,
    )
  async {

    final now = (month ?? DateTime.now());

    final monthStart =
        DateTime(
      now.year,
      now.month,
      1,
    );

    // final transactions =
    //     await isar
    //         .transactionModels
    //         .filter()
    //         .typeEqualTo(
    //           'expense',
    //         )
    //         .transactionDateGreaterThan(
    //           monthStart,
    //         )
    //         .isDeletedEqualTo(
    //           false,
    //         )
    //         .findAll();

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
            .typeEqualTo(
              'expense',
            )
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

    double expense = 0;

    for (final t
        in transactions) {

      expense +=
          t.amount / 100;
    }

    // final daysPassed =
    //     now.day;

    // final totalDays =
    //     DateTime(
    //       now.year,
    //       now.month + 1,
    //       0,
    //     ).day;

    // final dailyAverage =
    //     expense / daysPassed;

    // final projected =
    //     dailyAverage *
    //         totalDays;

    final today = DateTime.now();

    final totalDays = DateTime(
      now.year,
      now.month + 1,
      0,
    ).day;

    final selectedMonthStart = DateTime(
      now.year,
      now.month,
      1,
    );

    final currentMonthStart = DateTime(
      today.year,
      today.month,
      1,
    );

    final bool isCurrentMonth =
        selectedMonthStart == currentMonthStart;

    final bool isPastMonth =
        selectedMonthStart.isBefore(
          currentMonthStart,
        );

    final int daysPassed;

    if (isCurrentMonth) {
      daysPassed = today.day;
    } else if (isPastMonth) {
      daysPassed = totalDays;
    } else {
      daysPassed = 0;
    }

    final dailyAverage =
        daysPassed == 0
            ? 0.0
            : expense / daysPassed;

    final projected =
        daysPassed == 0
            ? expense
            : dailyAverage * totalDays;

    // if (daysPassed < 3) {
    if (isCurrentMonth && daysPassed < 3) {
      
      return ExpenseForecastModel(

        currentExpense:
            expense,

        projectedExpense:
            expense,

        dailyAverage:
            dailyAverage,

        daysPassed:
            daysPassed,

        totalDays:
            totalDays,
      );
    }

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