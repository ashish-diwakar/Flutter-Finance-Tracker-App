import 'package:flutter/material.dart';

import '../../../../core/utils/currency_formatter.dart';

import '../../domain/models/expense_forecast_model.dart';

class ExpenseForecastCard
    extends StatelessWidget {

  final ExpenseForecastModel
      forecast;

  const ExpenseForecastCard({
    super.key,
    required this.forecast,
  });

  @override
  Widget build(
    BuildContext context,
  ) {

    final projected =
        forecast
            .projectedExpense;

    final current =
        forecast
            .currentExpense;

    final remaining =
        projected - current;

    return Card(

      child: Padding(

        padding:
            const EdgeInsets.all(
          20,
        ),

        child: Column(

          crossAxisAlignment:
              CrossAxisAlignment.start,

          children: [

            Row(

              children: [

                const Icon(
                  Icons.insights,
                ),

                const SizedBox(
                  width: 8,
                ),

                const Text(

                  'Expense Forecast',

                  style: TextStyle(

                    fontSize: 18,

                    fontWeight:
                        FontWeight.bold,
                  ),
                ),
              ],
            ),

            const SizedBox(
              height: 20,
            ),

            Text(

              CurrencyFormatter.format(
                (projected * 100)
                    .round(),
              ),

              style:
                  const TextStyle(

                fontSize: 32,

                fontWeight:
                    FontWeight.bold,
              ),
            ),

            const SizedBox(
              height: 8,
            ),

            const Text(
              'Projected month-end expense',
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
            ),

            const SizedBox(
              height: 16,
            ),

            Text(

              'Daily average: ${CurrencyFormatter.format((forecast.dailyAverage * 100).round())}',
            ),

            const SizedBox(
              height: 8,
            ),

            Text(

              'Estimated remaining spending: ${CurrencyFormatter.format((remaining * 100).round())}',
            ),
          ],
        ),
      ),
    );
  }
}