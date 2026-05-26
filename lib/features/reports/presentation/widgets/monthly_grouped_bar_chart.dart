import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../domain/models/monthly_chart_data.dart';

class MonthlyGroupedBarChart
    extends StatelessWidget {

  final List<MonthlyChartData>
      data;

  const MonthlyGroupedBarChart({
    super.key,
    required this.data,
  });

  @override
  Widget build(BuildContext context) {

    if (data.isEmpty) {

      return const Center(
        child: Text(
          'No monthly data',
        ),
      );
    }

    final maxY =
        data.fold<double>(
      0,
      (previousValue, element) {

        final max =
            element.income >
                    element.expense
                ? element.income
                : element.expense;

        return max >
                previousValue
            ? max
            : previousValue;
      },
    );

    return Column(

      crossAxisAlignment:
          CrossAxisAlignment.start,

      children: [

        const Text(

          'Overall Monthly Income vs Expense Comparison',

          style: TextStyle(

            fontSize: 18,

            fontWeight:
                FontWeight.bold,
          ),
        ),

        const SizedBox(height: 4),

        const Text(

          'Analyze income and expense trends',

          style: TextStyle(
            color: Colors.grey,
          ),
        ),

        const SizedBox(
          height: 20,
        ),

        SizedBox(

          height: 320,

          child: BarChart(

            BarChartData(

              maxY: maxY * 1.2,

              borderData:
                  FlBorderData(
                show: false,
              ),

              gridData:
                  const FlGridData(
                show: true,
              ),

              titlesData:
                  FlTitlesData(

                topTitles:
                    const AxisTitles(
                  sideTitles:
                      SideTitles(
                    showTitles:
                        false,
                  ),
                ),

                rightTitles:
                    const AxisTitles(
                  sideTitles:
                      SideTitles(
                    showTitles:
                        false,
                  ),
                ),

                bottomTitles:
                    AxisTitles(

                  sideTitles:
                      SideTitles(

                    showTitles:
                        true,

                    getTitlesWidget:
                        (
                      value,
                      meta,
                    ) {

                      final index =
                          value
                              .toInt();

                      if (index <
                              0 ||
                          index >=
                              data
                                  .length) {

                        return const SizedBox();
                      }

                      return Padding(

                        padding:
                            const EdgeInsets.only(
                          top: 8,
                        ),

                        child: Text(
                          data[index]
                              .month,
                          style:
                              const TextStyle(
                            fontSize:
                                10,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),

              barGroups:
                  List.generate(
                data.length,
                (index) {

                  final item =
                      data[index];

                  return BarChartGroupData(

                    x: index,

                    barsSpace: 4,

                    barRods: [

                      BarChartRodData(

                        toY:
                            item.income,

                        width: 12,

                        borderRadius:
                            BorderRadius.circular(
                          4,
                        ),

                        color:
                            Colors.green,
                      ),

                      BarChartRodData(

                        toY:
                            item.expense,

                        width: 12,

                        borderRadius:
                            BorderRadius.circular(
                          4,
                        ),

                        color:
                            Colors.red,
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ),

        const SizedBox(
          height: 16,
        ),

        Wrap(

          spacing: 16,

          children: [

            Row(

              mainAxisSize:
                  MainAxisSize.min,

              children: [

                Container(
                  width: 14,
                  height: 14,
                  color:
                      Colors.green,
                ),

                const SizedBox(
                  width: 6,
                ),

                const Text(
                  'Income',
                ),
              ],
            ),

            Row(

              mainAxisSize:
                  MainAxisSize.min,

              children: [

                Container(
                  width: 14,
                  height: 14,
                  color:
                      Colors.red,
                ),

                const SizedBox(
                  width: 6,
                ),

                const Text(
                  'Expense',
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }
}