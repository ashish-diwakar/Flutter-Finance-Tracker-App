import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/budget_progress_provider.dart';
import '../providers/category_analytics_provider.dart';
import '../providers/monthly_chart_provider.dart';
import '../providers/monthly_summary_provider.dart';
import '../providers/monthly_trends_provider.dart';
import '../providers/expense_forecast_provider.dart';

import '../widgets/budget_progress_chart.dart';
import '../widgets/expense_donut_chart.dart';
import '../widgets/expense_forecast_card.dart';
import '../widgets/expense_pie_chart.dart';
import '../widgets/monthly_grouped_bar_chart.dart';
import '../widgets/monthly_summary_card.dart';
import '../widgets/monthly_trend_chart.dart';

import 'budget_alerts_screen.dart';

enum ReportChartType {

  pie,

  donut,

  groupedBar,

  progress,

  trends,
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

  Future<void> refreshReports()
  async {

    ref.invalidate(
      monthlySummaryProvider(
        selectedMonth,
      ),
    );

    ref.invalidate(
      categoryAnalyticsProvider(
        selectedMonth,
      ),
    );

    ref.invalidate(
      monthlyChartProvider,
    );

    ref.invalidate(
      budgetProgressProvider,
    );

    ref.invalidate(
      monthlyTrendsProvider,
    );

    ref.invalidate(
      expenseForecastProvider,
    );
  }

  @override
  Widget build(
    BuildContext context,
  ) {

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

    final budgetAsync =
        ref.watch(
      budgetProgressProvider,
    );

    final trendsAsync =
        ref.watch(
      monthlyTrendsProvider,
    );

    final forecastAsync =
        ref.watch(
      expenseForecastProvider,
    );

    return Scaffold(

      appBar: AppBar(

        title: const Text(
          'Reports',
        ),

        actions: [

          IconButton(

            onPressed: () async {

              await refreshReports();

              if (mounted) {

                setState(() {});
              }
            },

            icon: const Icon(
              Icons.refresh,
            ),
          ),
        ],
      ),

      body: RefreshIndicator(

        onRefresh:
            refreshReports,

        child: ListView(

          physics:
              const AlwaysScrollableScrollPhysics(),

          padding:
              const EdgeInsets.fromLTRB(
            16,
            16,
            16,
            40,
          ),

          children: [

            // =====================================================
            // MONTH SELECTOR
            // =====================================================

            Card(

              child: ListTile(

                shape:
                    RoundedRectangleBorder(

                  borderRadius:
                      BorderRadius.circular(
                    12,
                  ),
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

                  if (picked != null &&
                      mounted) {

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
            ),

            const SizedBox(
              height: 16,
            ),

            // =====================================================
            // MONTHLY SUMMARY
            // =====================================================

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
                          EdgeInsets.all(
                        16,
                      ),

                      child: Text(
                        'Unable to load summary',
                      ),
                    ),
                  ),

              loading: () =>

                  const Padding(

                    padding:
                        EdgeInsets.all(
                      24,
                    ),

                    child: Center(

                      child:
                          CircularProgressIndicator(),
                    ),
                  ),
            ),

            const SizedBox(
              height: 16,
            ),

            // =====================================================
            // FORECAST SECTION
            // =====================================================

            const Text(

              'Financial Forecast',

              style: TextStyle(

                fontSize: 20,

                fontWeight:
                    FontWeight.bold,
              ),
            ),

            const SizedBox(
              height: 6,
            ),

            const Text(

              'Predict future spending patterns based on current behavior.',

              style: TextStyle(
                color: Colors.grey,
              ),
            ),

            const SizedBox(
              height: 16,
            ),

            forecastAsync.when(

              data: (forecast) {

                return ExpenseForecastCard(
                  forecast: forecast,
                );
              },

              error: (_, __) =>

                  const Card(

                    child: Padding(

                      padding:
                          EdgeInsets.all(
                        16,
                      ),

                      child: Text(
                        'Unable to generate forecast',
                      ),
                    ),
                  ),

              loading: () =>

                  const Center(

                    child: Padding(

                      padding:
                          EdgeInsets.all(
                        24,
                      ),

                      child:
                          CircularProgressIndicator(),
                    ),
                  ),
            ),

            const SizedBox(
              height: 20,
            ),

            // =====================================================
            // BUDGET ALERTS BUTTON
            // =====================================================

            SizedBox(

              width: double.infinity,

              child: OutlinedButton.icon(

                onPressed: () {

                  Navigator.push(

                    context,

                    MaterialPageRoute(

                      builder: (_) =>
                          const BudgetAlertsScreen(),
                    ),
                  );
                },

                icon: const Icon(
                  Icons.warning_amber,
                ),

                label: const Text(
                  'View Budget Alerts',
                ),
              ),
            ),

            const SizedBox(
              height: 28,
            ),

            // =====================================================
            // ANALYTICS HEADER
            // =====================================================

            const Text(

              'Expense Analytics',

              style: TextStyle(

                fontSize: 20,

                fontWeight:
                    FontWeight.bold,
              ),
            ),

            const SizedBox(
              height: 6,
            ),

            const Text(

              'Visualize spending trends, category distribution and financial performance.',

              style: TextStyle(
                color: Colors.grey,
              ),
            ),

            const SizedBox(
              height: 20,
            ),

            // =====================================================
            // CHART TYPE
            // =====================================================

            const Text(

              'Chart Type',

              style: TextStyle(

                fontWeight:
                    FontWeight.w600,
              ),
            ),

            const SizedBox(
              height: 12,
            ),

            SingleChildScrollView(

              scrollDirection:
                  Axis.horizontal,

              child: SegmentedButton<
                  ReportChartType>(

                showSelectedIcon:
                    false,

                style: ButtonStyle(

                  visualDensity:
                      VisualDensity.compact,

                  padding:
                      WidgetStateProperty.all(

                    const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 12,
                    ),
                  ),
                ),

                segments: const [

                  ButtonSegment(

                    value:
                        ReportChartType
                            .donut,

                    icon: Icon(
                      Icons.donut_large,
                    ),

                    tooltip:
                        'Donut Chart',
                  ),

                  ButtonSegment(

                    value:
                        ReportChartType
                            .pie,

                    icon: Icon(
                      Icons.pie_chart,
                    ),

                    tooltip:
                        'Pie Chart',
                  ),

                  ButtonSegment(

                    value:
                        ReportChartType
                            .groupedBar,

                    icon: Icon(
                      Icons.bar_chart,
                    ),

                    tooltip:
                        'Bar Chart',
                  ),

                  ButtonSegment(

                    value:
                        ReportChartType
                            .progress,

                    icon: Icon(
                      Icons.linear_scale,
                    ),

                    tooltip:
                        'Budget Progress',
                  ),

                  ButtonSegment(

                    value:
                        ReportChartType
                            .trends,

                    icon: Icon(
                      Icons.show_chart,
                    ),

                    tooltip:
                        'Monthly Trends',
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
            ),

            const SizedBox(
              height: 28,
            ),

            // =====================================================
            // CHART TITLE
            // =====================================================

            Builder(

              builder: (_) {

                String title;
                String subtitle;

                switch (
                    selectedChart) {

                  case ReportChartType
                        .donut:

                    title =
                        'Expense Distribution';

                    subtitle =
                        'Analyze proportional category spending with a modern donut chart.';

                    break;

                  case ReportChartType
                        .pie:

                    title =
                        'Expense Share Analysis';

                    subtitle =
                        'View category-wise contribution to total expenses.';

                    break;

                  case ReportChartType
                        .groupedBar:

                    title =
                        'Income vs Expense';

                    subtitle =
                        'Compare monthly income and expense performance.';

                    break;

                  case ReportChartType
                        .progress:

                    title =
                        'Budget Utilization';

                    subtitle =
                        'Track budget consumption across categories.';

                    break;

                  case ReportChartType
                        .trends:

                    title =
                        'Monthly Trends';

                    subtitle =
                        'Track financial growth and spending patterns over time.';

                    break;
                }

                return Column(

                  crossAxisAlignment:
                      CrossAxisAlignment
                          .start,

                  children: [

                    Text(

                      title,

                      style:
                          const TextStyle(

                        fontSize: 18,

                        fontWeight:
                            FontWeight.bold,
                      ),
                    ),

                    const SizedBox(
                      height: 6,
                    ),

                    Text(

                      subtitle,

                      style:
                          const TextStyle(
                        color:
                            Colors.grey,
                      ),
                    ),
                  ],
                );
              },
            ),

            const SizedBox(
              height: 20,
            ),

            // =====================================================
            // CHART CONTENT
            // =====================================================

            AnimatedSwitcher(

              duration:
                  const Duration(
                milliseconds: 300,
              ),

              child: Builder(

                key: ValueKey(
                  selectedChart,
                ),

                builder: (_) {

                  // =========================================
                  // GROUPED BAR CHART
                  // =========================================

                  if (selectedChart ==
                      ReportChartType
                          .groupedBar) {

                    return monthlyChartAsync
                        .when(

                      data:
                          (monthlyData) {

                        return MonthlyGroupedBarChart(
                          data:
                              monthlyData,
                        );
                      },

                      error:
                          (_, __) =>

                              const Card(

                        child:
                            Padding(

                          padding:
                              EdgeInsets.all(
                            16,
                          ),

                          child: Text(
                            'Unable to load monthly chart',
                          ),
                        ),
                      ),

                      loading: () =>

                          const Center(

                        child:
                            Padding(

                          padding:
                              EdgeInsets.all(
                            24,
                          ),

                          child:
                              CircularProgressIndicator(),
                        ),
                      ),
                    );
                  }

                  // =========================================
                  // BUDGET CHART
                  // =========================================

                  if (selectedChart ==
                      ReportChartType
                          .progress) {

                    return budgetAsync.when(

                      data:
                          (budgetData) {

                        if (budgetData
                            .isEmpty) {

                          return const Card(

                            child:
                                Padding(

                              padding:
                                  EdgeInsets.all(
                                24,
                              ),

                              child:
                                  Center(

                                child: Text(
                                  'No budget data available',
                                ),
                              ),
                            ),
                          );
                        }

                        return BudgetProgressChart(
                          data:
                              budgetData,
                        );
                      },

                      error:
                          (_, __) =>

                              const Card(

                        child:
                            Padding(

                          padding:
                              EdgeInsets.all(
                            16,
                          ),

                          child: Text(
                            'Unable to load budget chart',
                          ),
                        ),
                      ),

                      loading: () =>

                          const Center(

                        child:
                            Padding(

                          padding:
                              EdgeInsets.all(
                            24,
                          ),

                          child:
                              CircularProgressIndicator(),
                        ),
                      ),
                    );
                  }

                  // =========================================
                  // TRENDS CHART
                  // =========================================

                  if (selectedChart ==
                      ReportChartType
                          .trends) {

                    return trendsAsync.when(

                      data: (trends) {

                        if (trends
                            .isEmpty) {

                          return const Card(

                            child:
                                Padding(

                              padding:
                                  EdgeInsets.all(
                                24,
                              ),

                              child:
                                  Center(

                                child: Text(
                                  'No trend data available',
                                ),
                              ),
                            ),
                          );
                        }

                        return MonthlyTrendChart(
                          trends: trends,
                        );
                      },

                      error:
                          (_, __) =>

                              const Card(

                        child:
                            Padding(

                          padding:
                              EdgeInsets.all(
                            16,
                          ),

                          child: Text(
                            'Unable to load trend analytics',
                          ),
                        ),
                      ),

                      loading: () =>

                          const Center(

                        child:
                            Padding(

                          padding:
                              EdgeInsets.all(
                            24,
                          ),

                          child:
                              CircularProgressIndicator(),
                        ),
                      ),
                    );
                  }

                  // =========================================
                  // PIE & DONUT CHARTS
                  // =========================================

                  return categoryAsync.when(

                    data: (categories) {

                      if (categories
                          .isEmpty) {

                        return const Card(

                          child: Padding(

                            padding:
                                EdgeInsets.all(
                              24,
                            ),

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
                              .donut) {

                        return ExpenseDonutChart(
                          data:
                              categories,
                        );
                      }

                      return ExpensePieChart(

                        categories:
                            categories,

                        colors:
                            colors,

                        forecolors:
                            List.generate(

                          colors.length,

                          (_) =>
                              Colors.black,
                        ),
                      );
                    },

                    error:
                        (_, __) =>

                            const Card(

                      child:
                          Padding(

                        padding:
                            EdgeInsets.all(
                          16,
                        ),

                        child: Text(
                          'Unable to load analytics',
                        ),
                      ),
                    ),

                    loading: () =>

                        const Center(

                      child:
                          Padding(

                        padding:
                            EdgeInsets.all(
                          24,
                        ),

                        child:
                            CircularProgressIndicator(),
                      ),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(
              height: 40,
            ),
          ],
        ),
      ),
    );
  }
}