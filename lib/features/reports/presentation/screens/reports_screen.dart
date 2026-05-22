import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/category_analytics_provider.dart';
import '../providers/monthly_summary_provider.dart';
import '../widgets/expense_donut_chart.dart';
import '../widgets/expense_pie_chart.dart';
import '../widgets/monthly_summary_card.dart';
import '../providers/monthly_chart_provider.dart';
import '../widgets/monthly_grouped_bar_chart.dart';

enum ReportChartType {

  pie,

  donut,

  groupedBar,
}

class ReportsScreen
    extends ConsumerStatefulWidget {

  const ReportsScreen({
    super.key,
  });

  @override
  ConsumerState<ReportsScreen>
      createState() =>
          _ReportsScreenState();
}

class _ReportsScreenState
    extends ConsumerState<
        ReportsScreen> {

  DateTime selectedMonth =
      DateTime.now();

  ReportChartType selectedChart =
      ReportChartType.donut;

  @override
  Widget build(BuildContext context) {

    final summaryAsync =
        ref.watch(
      monthlySummaryProvider(
        selectedMonth,
      ),
    );

    final categoryAsync =
        ref.watch(
      categoryAnalyticsProvider(
        selectedMonth,
      ),
    );

    final monthlyChartAsync =
        ref.watch(
      monthlyChartProvider,
    );

    return Scaffold(

      appBar: AppBar(
        title: const Text(
          'Reports',
        ),
      ),

      body: ListView(

        padding:
            const EdgeInsets.all(16),

        children: [

          ListTile(

            shape:
                RoundedRectangleBorder(

              borderRadius:
                  BorderRadius.circular(
                8,
              ),

              side:
                  const BorderSide(),
            ),

            title: const Text(
              'Selected Month',
            ),

            subtitle: Text(
              '${selectedMonth.month}/${selectedMonth.year}',
            ),

            trailing: const Icon(
              Icons.calendar_today,
            ),

            onTap: () async {

              final picked =
                  await showDatePicker(

                context: context,

                initialDate:
                    selectedMonth,

                firstDate:
                    DateTime(2020),

                lastDate:
                    DateTime(2100),
              );

              if (picked != null) {

                setState(() {

                  selectedMonth =
                      DateTime(
                    picked.year,
                    picked.month,
                  );
                });
              }
            },
          ),

          const SizedBox(
            height: 16,
          ),

          summaryAsync.when(

            data: (summary) {

              return MonthlySummaryCard(

                income:
                    summary.income,

                expense:
                    summary.expense,
              );
            },

            error: (_, __) =>

                const Card(

                  child: Padding(

                    padding:
                        EdgeInsets.all(16),

                    child: Text(
                      'Unable to load summary',
                    ),
                  ),
                ),

            loading: () =>

                const Center(
                  child:
                      CircularProgressIndicator(),
                ),
          ),

          const SizedBox(
            height: 24,
          ),

          const Text(

            'Expense Analytics',

            style: TextStyle(

              fontSize: 18,

              fontWeight:
                  FontWeight.bold,
            ),
          ),

          const SizedBox(
            height: 16,
          ),

          SegmentedButton<
              ReportChartType>(

            segments: const [

              ButtonSegment(
                value:
                    ReportChartType
                        .donut,

                label: Text(
                  'Donut',
                ),

                icon: Icon(
                  Icons.donut_large,
                ),
              ),

              ButtonSegment(
                value:
                    ReportChartType
                        .pie,

                label: Text(
                  'Pie',
                ),

                icon: Icon(
                  Icons.pie_chart,
                ),
              ),

              ButtonSegment(
                value:
                    ReportChartType
                        .groupedBar,

                label: Text(
                  'Bar',
                ),

                icon: Icon(
                  Icons.bar_chart,
                ),
              ),

            ],

            selected: {
              selectedChart,
            },

            onSelectionChanged:
                (value) {

              setState(() {

                selectedChart =
                    value.first;
              });
            },
          ),

          const SizedBox(
            height: 24,
          ),

          categoryAsync.when(

            data: (categories) {

              if (categories
                  .isEmpty) {

                return const Card(

                  child: Padding(

                    padding:
                        EdgeInsets.all(24),

                    child: Center(

                      child: Text(
                        'No expense data available',
                      ),
                    ),
                  ),
                );
              }

              final colors = const [

                Colors.red,

                Colors.blue,

                Colors.green,

                Colors.orange,

                Colors.purple,

                Colors.teal,

                Colors.indigo,

                Colors.pink,
              ];

              if (selectedChart ==
                  ReportChartType
                      .groupedBar) {

                return monthlyChartAsync.when(

                  data: (monthlyData) {

                    return MonthlyGroupedBarChart(
                      data: monthlyData,
                    );
                  },

                  error: (_, __) =>

                      const Text(
                        'Unable to load Monthly grouped bar chart',
                      ),

                  loading: () =>

                      const Center(
                        child:
                            CircularProgressIndicator(),
                      ),
                );
              }

              if (selectedChart ==
                  ReportChartType
                      .donut) {

                return ExpenseDonutChart(

                  data:
                      categories,
                );
              }

              return ExpensePieChart(

                categories:
                    categories,

                colors: colors,

                forecolors:
                    List.generate(
                  colors.length,
                  (_) => Colors.black,
                ),
              );
            },

            error: (_, __) =>

                const Card(

                  child: Padding(

                    padding:
                        EdgeInsets.all(16),

                    child: Text(
                      'Unable to load analytics',
                    ),
                  ),
                ),

            loading: () =>

                const Center(
                  child:
                      CircularProgressIndicator(),
                ),
          ),

          const SizedBox(
            height: 32,
          ),
        ],
      ),
    );
  }
}