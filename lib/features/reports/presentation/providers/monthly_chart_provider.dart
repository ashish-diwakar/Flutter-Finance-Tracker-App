
import 'package:isar/isar.dart';
import 'package:finance_tracker/shared/providers/database_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:finance_tracker/shared/models/transaction_model.dart';

import '../../domain/models/monthly_chart_data.dart';

final monthlyChartProvider =
    FutureProvider<
        List<MonthlyChartData>>(
  (ref) async {

    final isar =
        await ref.read(
      isarProvider.future,
    );

    final transactions =
        await isar.transactionModels
            .filter()
            .isDeletedEqualTo(false)
            .findAll();

    final Map<String, double>
        incomeMap = {};

    final Map<String, double>
        expenseMap = {};

    for (final transaction
        in transactions) {

      final date =
          transaction.transactionDate;

      final key =
          '${date.month}/${date.year}';

      final amount =
          transaction.amount / 100;

      if (transaction.type ==
          'income') {

        incomeMap.update(
          key,
          (value) =>
              value + amount,

          ifAbsent: () => amount,
        );

      } else {

        expenseMap.update(
          key,
          (value) =>
              value + amount,

          ifAbsent: () => amount,
        );
      }
    }

    final months = {

      ...incomeMap.keys,
      ...expenseMap.keys,
    }.toList();

    months.sort((a, b) {

      final aParts =
          a.split('/');

      final bParts =
          b.split('/');

      final aDate =
          DateTime(
        int.parse(aParts[1]),
        int.parse(aParts[0]),
      );

      final bDate =
          DateTime(
        int.parse(bParts[1]),
        int.parse(bParts[0]),
      );

      return aDate.compareTo(
        bDate,
      );
    });

    return months.map((month) {

      return MonthlyChartData(

        month: month,

        income:
            incomeMap[month] ?? 0,

        expense:
            expenseMap[month] ?? 0,
      );
    }).toList();
  },
);