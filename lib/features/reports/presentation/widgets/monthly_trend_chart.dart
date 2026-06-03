import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../domain/models/monthly_trend_model.dart';

class MonthlyTrendChart
    extends StatelessWidget {

  final List<MonthlyTrendModel>
      trends;

  const MonthlyTrendChart({
    super.key,
    required this.trends,
  });

  @override
  Widget build(
    BuildContext context,
  ) {

    if (trends.isEmpty) {

      return const SizedBox();
    }

    // =====================================================
    // CALCULATE MAX VALUE
    // =====================================================

    double maxY = 0;

    for (final trend
        in trends) {

      if (trend.income > maxY) {

        maxY =
            trend.income;
      }

      if (trend.expense > maxY) {

        maxY =
            trend.expense;
      }
    }

    maxY =
        (maxY * 1.2).clamp(
      100,
      double.infinity,
    );

    final interval =
        maxY / 5;

    return Card(

      child: Padding(

        padding:
            const EdgeInsets.fromLTRB(
          12,
          24,
          24,
          16,
        ),

        child: Column(

          children: [ 
            
            SizedBox(

                height: 320,

                child: LineChart(

                  LineChartData(

                    minY: 0,

                    maxY: maxY,

                    // =========================================
                    // GRID
                    // =========================================

                    gridData:
                        FlGridData(

                      show: true,

                      drawVerticalLine:
                          false,

                      horizontalInterval:
                          interval,
                    ),

                    // =========================================
                    // BORDER
                    // =========================================

                    borderData:
                        FlBorderData(

                      show: true,

                      border: Border.all(
                        color:
                            Colors.grey,
                      ),
                    ),

                    // =========================================
                    // TITLES
                    // =========================================

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

                      // =====================================
                      // LEFT TITLES
                      // =====================================

                      leftTitles:
                          AxisTitles(

                        sideTitles:
                            SideTitles(

                          showTitles:
                              true,

                          reservedSize:
                              52,

                          interval:
                              interval,

                          getTitlesWidget:
                              (
                            value,
                            meta,
                          ) {

                            String text;

                            if (value >=
                                1000) {

                              text =
                                  '${(value / 1000).toStringAsFixed(1)}K';

                            } else {

                              text =
                                  value
                                      .toStringAsFixed(
                                    0,
                                  );
                            }

                            return SideTitleWidget(

                              meta: meta,

                              child: Text(

                                text,

                                style:
                                    const TextStyle(
                                  fontSize:
                                      11,
                                ),
                              ),
                            );
                          },
                        ),
                      ),

                      // =====================================
                      // BOTTOM TITLES
                      // =====================================

                      bottomTitles:
                          AxisTitles(

                        sideTitles:
                            SideTitles(

                          showTitles:
                              true,

                          reservedSize:
                              40,

                          interval: 1,

                          getTitlesWidget:
                              (
                            value,
                            meta,
                          ) {

                            final index =
                                value
                                    .toInt();

                            if (index < 0 ||
                                index >=
                                    trends.length) {

                              return const SizedBox();
                            }

                            final raw =
                                trends[index]
                                    .month;

                            final parts =
                                raw.split(
                              '-',
                            );

                            if (parts.length !=
                                2) {

                              return const SizedBox();
                            }

                            final month =
                                int.tryParse(
                              parts[1],
                            );

                            const monthNames = [

                              'Jan',
                              'Feb',
                              'Mar',
                              'Apr',
                              'May',
                              'Jun',
                              'Jul',
                              'Aug',
                              'Sep',
                              'Oct',
                              'Nov',
                              'Dec',
                            ];

                            final label =
                                month != null &&
                                        month >= 1 &&
                                        month <= 12

                                    ? monthNames[
                                        month - 1
                                      ]

                                    : raw;

                            return SideTitleWidget(

                              meta: meta,

                              child: Padding(

                                padding:
                                    const EdgeInsets.only(
                                  top: 8,
                                ),

                                child: Text(

                                  label,

                                  style:
                                      const TextStyle(
                                    fontSize:
                                        11,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),

                    // =========================================
                    // LINE BARS
                    // =========================================

                    lineBarsData: [

                      // =====================================
                      // INCOME
                      // =====================================

                      LineChartBarData(

                        spots:
                            trends
                                .asMap()
                                .entries
                                .map(
                          (e) {

                            return FlSpot(

                              e.key
                                  .toDouble(),

                              e.value
                                  .income,
                            );
                          },
                        ).toList(),

                        isCurved: true,

                        color: Colors.green,

                        barWidth: 4,

                        dotData:
                            FlDotData(

                          show: true,

                          getDotPainter:
                              (
                            spot,
                            percent,
                            bar,
                            index,
                          ) {

                            return FlDotCirclePainter(

                              radius: 4,

                              color: Colors.green,

                              strokeWidth: 1.5,

                              strokeColor:
                                  Colors.white,
                            );
                          },
                        ),

                        belowBarData:
                            BarAreaData(
                          show: false,
                        ),
                      ),

                      // =====================================
                      // EXPENSE
                      // =====================================

                      LineChartBarData(

                        spots:
                            trends
                                .asMap()
                                .entries
                                .map(
                          (e) {

                            return FlSpot(

                              e.key
                                  .toDouble(),

                              e.value
                                  .expense,
                            );
                          },
                        ).toList(),

                        isCurved: true,

                        color: Colors.red,

                        barWidth: 4,

                        dotData:
                            FlDotData(

                          show: true,

                          getDotPainter:
                              (
                            spot,
                            percent,
                            bar,
                            index,
                          ) {

                            return FlDotCirclePainter(

                              radius: 4,

                              color: Colors.red,

                              strokeWidth: 1.5,

                              strokeColor:
                                  Colors.white,
                            );
                          },
                        ),

                        belowBarData:
                            BarAreaData(
                          show: false,
                        ),
                      ),
                    ],
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
          ]
        ),

      ),
    );
  }
}