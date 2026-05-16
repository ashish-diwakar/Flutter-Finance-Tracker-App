import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/category_analytics_provider.dart';
import '../providers/monthly_summary_provider.dart';
import '../widgets/expense_pie_chart.dart';
import '../widgets/monthly_summary_card.dart';

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
    extends ConsumerState<ReportsScreen> {

  DateTime selectedMonth =
      DateTime.now();

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

    return Scaffold(

      appBar: AppBar(
        title: const Text('Reports'),
      ),

      body: ListView(

        padding:
            const EdgeInsets.all(16),

        children: [

          ListTile(

            shape: RoundedRectangleBorder(
              borderRadius:
                  BorderRadius.circular(8),
              side: const BorderSide(),
            ),

            title:
                const Text('Selected Month'),

            subtitle: Text(
              '${selectedMonth.month}/${selectedMonth.year}',
            ),

            trailing:
                const Icon(Icons.calendar_today),

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

          const SizedBox(height: 16),

          summaryAsync.when(

            data: (summary) {

              return MonthlySummaryCard(
                income: summary.income,
                expense: summary.expense,
              );
            },

            error: (e, s) =>
                Text(e.toString()),

            loading: () =>
                const Center(
              child:
                  CircularProgressIndicator(),
            ),
          ),

          const SizedBox(height: 24),

          const Text(
            'Expense Breakdown',
            style: TextStyle(
              fontSize: 18,
              fontWeight:
                  FontWeight.bold,
            ),
          ),

          const SizedBox(height: 16),

          categoryAsync.when(

            data: (categories) {

              return ExpensePieChart(
                categories:
                    categories,
              );
            },

            error: (e, s) =>
                Text(e.toString()),

            loading: () =>
                const Center(
              child:
                  CircularProgressIndicator(),
            ),
          ),
        ],
      ),
    );
  }
}