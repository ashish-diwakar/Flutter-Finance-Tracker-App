import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../shared/utils/provider_refresh_helper.dart';
import '../providers/budget_progress_provider.dart';
import '../providers/category_analytics_provider.dart';
import '../providers/expense_forecast_provider.dart';
import '../providers/financial_insights_provider.dart';
import '../providers/monthly_chart_provider.dart';
import '../providers/monthly_summary_provider.dart';
import '../providers/monthly_trends_provider.dart';

import '../widgets/budget_progress_chart.dart';
import '../widgets/expense_donut_chart.dart';
import '../widgets/expense_forecast_card.dart';
import '../widgets/expense_pie_chart.dart';
import '../widgets/financial_insights_section.dart';
import '../widgets/monthly_grouped_bar_chart.dart';
import '../widgets/monthly_summary_card.dart';
import '../widgets/monthly_trend_chart.dart';

import '../providers/financial_health_provider.dart';
import '../widgets/financial_health_card.dart';

import '../../../recurring/presentation/providers/recurring_analytics_provider.dart';
import '../../../recurring/presentation/widgets/monthly_commitments_card.dart';

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
      DateTime.now().toUtc();

  ReportChartType selectedChart =
      ReportChartType.donut;

  Future<void> refreshReports()
  async {

    // ref.invalidate(
    //   monthlySummaryProvider(
    //     selectedMonth,
    //   ),
    // );

    // ref.invalidate(
    //   categoryAnalyticsProvider(
    //     selectedMonth,
    //   ),
    // );

    // ref.invalidate(
    //   monthlyChartProvider,
    // );

    // ref.invalidate(
    //   budgetProgressProvider,
    // );

    // ref.invalidate(
    //   monthlyTrendsProvider,
    // );

    // ref.invalidate(
    //   expenseForecastProvider,
    // );

    // ref.invalidate(
    //   financialInsightsProvider,
    // );

    // ref.invalidate(
    //   financialHealthProvider,
    // );

    // ref.invalidate(
    //   recurringAnalyticsProvider,
    // );

    // await Future.wait([
    //   ref.read(
    //     monthlySummaryProvider(
    //       selectedMonth,
    //     ).future,
    //   ),

    //   ref.read(
    //     categoryAnalyticsProvider(
    //       selectedMonth,
    //     ).future,
    //   ),

    //   ref.read(
    //     monthlyChartProvider.future,
    //   ),

    //   ref.read(
    //     budgetProgressProvider(selectedMonth).future,
    //   ),
    // ]);
    
    await ProviderRefreshHelper
      .refreshReportsData(ref, selectedMonth);

  }

  TextStyle get sectionTitleStyle {

    return const TextStyle(

      fontSize: 22,

      fontWeight:
          FontWeight.w700,
    );
  }

  TextStyle get sectionSubtitleStyle {

    return TextStyle(

      color:
          Colors.grey.shade600,

      height: 1.4,

      fontSize: 14,
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
      budgetProgressProvider(
        selectedMonth,
      ),
    );

    final trendsAsync =
        ref.watch(
      monthlyTrendsProvider,
    );

    final forecastAsync =
        ref.watch(
      expenseForecastProvider,
    );

    final insightsAsync =
        ref.watch(
      financialInsightsProvider,
    );

    final healthAsync =
        ref.watch(
      financialHealthProvider,
    );

    final recurringAsync =
        ref.watch(
      recurringAnalyticsProvider,
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
                  DateFormat(
                      'MMMM yyyy',
                    ).format(
                      selectedMonth,
                    ),
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
              height: 24,
            ),

            // =====================================================
            // FINANCIAL FORECAST
            // =====================================================

            Text(

              'Expense Forecast',

              style:
                  sectionTitleStyle,
            ),

            const SizedBox(
              height: 6,
            ),

            Text(

              'Projected spending trends based on recent financial activity.',

              style:
                  sectionSubtitleStyle,
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
              height: 32,
            ),

            // =====================================================
            // FINANCIAL HEALTH
            // =====================================================

            Text(

              'Financial Health Score',

              style:
                  sectionTitleStyle,
            ),

            const SizedBox(
              height: 6,
            ),

            Text(

              'Analyze your financial stability, savings discipline and spending efficiency.',

              style:
                  sectionSubtitleStyle,
            ),

            const SizedBox(
              height: 16,
            ),

            healthAsync.when(

              data: (health) {

                return FinancialHealthCard(
                  health: health,
                );
              },

              error: (_, __) =>
                  const SizedBox(),

              loading: () =>

                  const Center(

                    child:
                        CircularProgressIndicator(),
                  ),
            ),

            const SizedBox(
              height: 32,
            ),

            // =====================================================
            // RECURRING COMMITMENTS
            // =====================================================

            Text(

              'Monthly Commitments',

              style:
                  sectionTitleStyle,
            ),

            const SizedBox(
              height: 6,
            ),

            Text(

              'Track fixed monthly obligations and recurring financial commitments.',

              style:
                  sectionSubtitleStyle,
            ),

            const SizedBox(
              height: 16,
            ),

            recurringAsync.when(

              data: (analytics) {

                return MonthlyCommitmentsCard(
                  analytics: analytics,
                );
              },

              loading: () =>

                  const Center(

                    child:
                        CircularProgressIndicator(),
                  ),

              error: (_, __) =>
                  const SizedBox(),
            ),

            const SizedBox(
              height: 32,
            ),

            // =====================================================
            // AI INSIGHTS
            // =====================================================

            insightsAsync.when(

              data: (insights) {

                return FinancialInsightsSection(
                  insights: insights,
                );
              },

              error: (_, __) =>

                  const SizedBox(),

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
              height: 24,
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
              height: 32,
            ),

            // =====================================================
            // ANALYTICS HEADER
            // =====================================================

            Text(

              'Financial Analytics',

              style:
                  sectionTitleStyle,
            ),

            const SizedBox(
              height: 6,
            ),

            Text(

              'Explore interactive insights across spending patterns, budgets and income trends.',

              style:
                  sectionSubtitleStyle,
            ),

            const SizedBox(
              height: 24,
            ),

            // =====================================================
            // CHART TYPE
            // =====================================================

            const Text(

              'Visualization Mode',

              style: TextStyle(

                fontWeight:
                    FontWeight.w600,

                fontSize: 15,
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
                  ),

                  ButtonSegment(

                    value:
                        ReportChartType
                            .pie,

                    icon: Icon(
                      Icons.pie_chart,
                    ),
                  ),

                  ButtonSegment(

                    value:
                        ReportChartType
                            .groupedBar,

                    icon: Icon(
                      Icons.bar_chart,
                    ),
                  ),

                  ButtonSegment(

                    value:
                        ReportChartType
                            .progress,

                    icon: Icon(
                      Icons.linear_scale,
                    ),
                  ),

                  ButtonSegment(

                    value:
                        ReportChartType
                            .trends,

                    icon: Icon(
                      Icons.show_chart,
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
            ),

            const SizedBox(
              height: 32,
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
                        'Spending Distribution';

                    subtitle =
                        'Understand how expenses are distributed across spending categories.';

                    break;

                  case ReportChartType
                        .pie:

                    title =
                        'Category Contribution';

                    subtitle =
                        'Compare category contribution to your total monthly spending.';

                    break;

                  case ReportChartType
                        .groupedBar:

                    title =
                        'Income & Expense Trends';

                    subtitle =
                        'Analyze monthly cash flow performance across income and expenses.';

                    break;

                  case ReportChartType
                        .progress:

                    title =
                        'Budget Performance';

                    subtitle =
                        'Monitor category-wise budget usage and spending efficiency.';

                    break;

                  case ReportChartType
                        .trends:

                    title =
                        'Financial Growth Trends';

                    subtitle =
                        'Visualize long-term income growth and expense movement patterns.';

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

                        fontSize: 20,

                        fontWeight:
                            FontWeight.w700,
                      ),
                    ),

                    const SizedBox(
                      height: 6,
                    ),

                    Text(

                      subtitle,

                      style:
                          TextStyle(

                        color:
                            Colors.grey.shade600,

                        height: 1.4,
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