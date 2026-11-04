import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/utils/currency_formatter.dart';
import '../../../../shared/providers/currency_provider.dart';

import '../../domain/models/expense_forecast_model.dart';

class ExpenseForecastCard
    extends ConsumerWidget {

  final ExpenseForecastModel
      forecast;

  const ExpenseForecastCard({
    super.key,
    required this.forecast,
  });

  @override
  Widget build(
    BuildContext context,
    WidgetRef ref,
  ) {

    final currency =
        ref.watch(
      currencyProvider,
    );

    final projected =
        forecast
            .projectedExpense;

    final current =
        forecast
            .currentExpense;

    final remaining =
        projected - current;

    return Column(

          crossAxisAlignment:
              CrossAxisAlignment.start,

          children: [

            Text(

              CurrencyFormatter.format(
                amount: (projected * 100)
                    .round(),
                currency: currency,
              ),

              style:
                  const TextStyle(

                color: Color(0xFF244C40),
                fontSize: 26,

                fontWeight:
                    FontWeight.bold,
              ),
            ),

            const SizedBox(
              height: 8,
            ),

            const Text(
              'Projected month-end expense',
              style: TextStyle(
                color: Color(0xFF536B61),
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),

            const SizedBox(
              height: 20,
            ),

            LinearProgressIndicator(

              value:
                  forecast.daysPassed /
                  forecast.totalDays,
            ),

            const SizedBox(
              height: 12,
            ),

            Text(

              '${forecast.daysPassed}/${forecast.totalDays} days completed',
              style: const TextStyle(
                color: Color(0xFF536B61),
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),

            const SizedBox(
              height: 16,
            ),

            Text(

              'Daily average: ${CurrencyFormatter.format(
                amount: (forecast.dailyAverage * 100).round(),
                currency: currency,
              )}',
              style: const TextStyle(
                color: Color(0xFF244C40),
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),

            const SizedBox(
              height: 8,
            ),

            Text(

              'Estimated remaining spending: ${CurrencyFormatter.format(
                amount: (remaining * 100).round(),
                currency: currency,
              )}',
              style: const TextStyle(
                color: Color(0xFF244C40),
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
    );
  }
}
