import 'package:isar_community/isar.dart';
import 'package:finance_tracker/shared/providers/database_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:finance_tracker/shared/models/transaction_model.dart';

import '../../domain/models/monthly_chart_data.dart';

final monthlyChartProvider =
    FutureProvider<List<MonthlyChartData>>(
  (ref) async {
    final isar = await ref.read(
      isarProvider.future,
    );

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

    final transactions =
        await isar.transactionModels
            .filter()
            .isDeletedEqualTo(false)
            .transactionDateBetween(
              startDate,
              endDate,
              includeLower: true,
              includeUpper: false,
            )
            .findAll();

    final Map<String, double> incomeMap = {};
    final Map<String, double> expenseMap = {};

    for (final transaction in transactions) {
      final date = transaction.transactionDate;

      final key =
          '${date.month}/${date.year}';

      final amount =
          transaction.amount / 100;

      if (transaction.type == 'income') {
        incomeMap.update(
          key,
          (value) => value + amount,
          ifAbsent: () => amount,
        );
      } else if (transaction.type == 'expense') {
        expenseMap.update(
          key,
          (value) => value + amount,
          ifAbsent: () => amount,
        );
      }
    }

    return List.generate(
      6,
      (index) {
        final monthDate = DateTime(
          startDate.year,
          startDate.month + index,
          1,
        );

        final key =
            '${monthDate.month}/${monthDate.year}';

        return MonthlyChartData(
          month: key,
          income: incomeMap[key] ?? 0,
          expense: expenseMap[key] ?? 0,
        );
      },
    );
  },
);