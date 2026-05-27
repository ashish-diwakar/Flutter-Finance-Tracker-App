import 'package:isar/isar.dart';

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

    final transactions =
        await isar
            .transactionModels
            .filter()
            .isDeletedEqualTo(
              false,
            )
            .findAll();

    final Map<String,
        MonthlyTrendModel>
        trends = {};

    for (final t
        in transactions) {

      final key =
          '${t.transactionDate.year}-${t.transactionDate.month}';

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

    final list =
        trends.values.toList();

    list.sort(
      (a, b) =>
          a.month.compareTo(
        b.month,
      ),
    );

    return list;
  }
}