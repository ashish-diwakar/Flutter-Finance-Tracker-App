import 'package:isar_community/isar.dart';

import '../../../../shared/models/transaction_model.dart';

import '../../domain/models/monthly_trend_model.dart';

class MonthlyTrendService {

  final Isar isar;

  MonthlyTrendService(
    this.isar,
  );

  Future<List<
      MonthlyTrendModel>>
      getMonthlyTrends()
  async {
    final now = DateTime.now();

    final startDate = DateTime(
      now.year,
      now.month - 5,
      1,
    );

    final endDate = DateTime(
      now.year,
      now.month + 1,
      1,
    );

    // final transactions =
    //     await isar
    //         .transactionModels
    //         .filter()
    //         .isDeletedEqualTo(
    //           false,
    //         )
    //         .findAll();

    final transactions =
    await isar
        .transactionModels
        .filter()
        .isDeletedEqualTo(false)
        .transactionDateBetween(
          startDate,
          endDate,
          includeLower: true,
          includeUpper: false,
        )
        .findAll();

    final Map<String,
        MonthlyTrendModel>
        trends = {};

    for (final t
        in transactions) {

      final key =
        '${t.transactionDate.year}-${t.transactionDate.month.toString().padLeft(2, '0')}';

      final existing =
          trends[key];

      double income =
          existing?.income ?? 0;

      double expense =
          existing?.expense ?? 0;

      final amount =
          t.amount / 100;

      if (t.type ==
          'income') {

        income += amount;

      } else {

        expense += amount;
      }

      trends[key] =
          MonthlyTrendModel(

        month: key,

        income: income,

        expense: expense,

        savings:
            income - expense,
      );
    }

    // final list =
        // trends.values.toList();

    // list.sort(
    //   (a, b) =>
    //       a.month.compareTo(
    //     b.month,
    //   ),
    // );
    // list.sort(
    //   (a, b) {

    //     final aParts =
    //         a.month.split('-');

    //     final bParts =
    //         b.month.split('-');

    //     final aDate =
    //         DateTime(
    //           int.parse(aParts[0]),
    //           int.parse(aParts[1]),
    //         );

    //     final bDate =
    //         DateTime(
    //           int.parse(bParts[0]),
    //           int.parse(bParts[1]),
    //         );

    //     return aDate.compareTo(
    //       bDate,
    //     );
    //   },
    // );
    final List<MonthlyTrendModel>
        list = [];

    for (int i = 0; i < 6; i++) {

      final monthDate =
          DateTime(
        startDate.year,
        startDate.month + i,
        1,
      );

      final key =
          '${monthDate.year}-${monthDate.month.toString().padLeft(2, '0')}';

      list.add(

        trends[key] ??

            MonthlyTrendModel(

              month: key,

              income: 0,

              expense: 0,

              savings: 0,
            ),
      );
    }

    return list;
  }
}