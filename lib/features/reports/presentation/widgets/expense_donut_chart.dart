import 'package:finance_tracker/features/reports/domain/models/category_expense_model.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/utils/currency_formatter.dart';
import '../../../../shared/providers/currency_provider.dart';

class ExpenseDonutChart
    extends ConsumerWidget {

  final List<CategoryExpenseModel>
      data;

  const ExpenseDonutChart({
    super.key,
    required this.data,
  });

  @override
  Widget build(
    BuildContext context,
    WidgetRef ref,
  ) {

    if (data.isEmpty) {

      return const Center(
        child: Text(
          'No expense data',
        ),
      );
    }

    final currency =
        ref.watch(
      currencyProvider,
    );

    final total =
        data.fold<int>(
      0,
      (
        previousValue,
        element,
      ) =>
          previousValue +
          element.amount,
    );

    final colors = [

      Colors.blue,
      Colors.red,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.teal,
      Colors.indigo,
      Colors.pink,
    ];

    return Column(

      crossAxisAlignment:
          CrossAxisAlignment.start,

      children: [

        const Text(

          'Expense Breakdown',

          style: TextStyle(

            fontSize: 18,

            fontWeight:
                FontWeight.bold,
          ),
        ),

        const SizedBox(
          height: 4,
        ),

        const Text(

          'See where your money goes',

          style: TextStyle(
            color: Colors.grey,
          ),
        ),

        const SizedBox(
          height: 20,
        ),

        SizedBox(

          height: 300,

          child: Stack(

            alignment:
                Alignment.center,

            children: [

              PieChart(

                PieChartData(

                  centerSpaceRadius:
                      70,

                  sectionsSpace: 2,

                  sections:
                      List.generate(

                    data.length,

                    (index) {

                      final item =
                          data[index];

                      final percentage =
                          (item.amount /
                                  total) *
                              100;

                      return PieChartSectionData(

                        value:
                            item.amount.toDouble(),

                        color:
                            colors[
                                index %
                                    colors
                                        .length],

                        radius: 60,

                        title:
                            '${percentage.toStringAsFixed(1)}%',

                        titleStyle:
                            const TextStyle(

                          fontSize: 12,

                          fontWeight:
                              FontWeight.bold,

                          color:
                              Colors.white,
                        ),
                      );
                    },
                  ),
                ),
              ),

              Column(

                mainAxisSize:
                    MainAxisSize.min,

                children: [

                  const Text(
                    'Total Expense',
                  ),

                  Text(

                    CurrencyFormatter
                        .format(

                      amount: total,

                      currency:
                          currency,
                    ),

                    style:
                        const TextStyle(

                      fontSize: 18,

                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        const SizedBox(
          height: 16,
        ),

        ListView.builder(

          shrinkWrap: true,

          physics:
              const NeverScrollableScrollPhysics(),

          itemCount:
              data.length,

          itemBuilder:
              (context, index) {

            final item =
                data[index];

            return Padding(

              padding:
                  const EdgeInsets.symmetric(
                vertical: 4,
              ),

              child: Row(

                children: [

                  Container(

                    width: 14,
                    height: 14,

                    decoration:
                        BoxDecoration(

                      color:
                          colors[index %
                              colors
                                  .length],

                      borderRadius:
                          BorderRadius.circular(
                        4,
                      ),
                    ),
                  ),

                  const SizedBox(
                    width: 8,
                  ),

                  Expanded(

                    child: Text(
                      item.category,
                    ),
                  ),

                  Text(

                    CurrencyFormatter
                        .format(

                      amount: item.amount,

                      currency:
                          currency,
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }
}
