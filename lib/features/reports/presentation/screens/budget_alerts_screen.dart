import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/services/budget_alert_checker.dart';
import '../providers/budget_alerts_provider.dart';
import '../widgets/budget_alerts_section.dart';

class BudgetAlertsScreen
    extends ConsumerWidget {
  final FinancialTargetType targetType;
  final DateTime? month;

  const BudgetAlertsScreen({
    super.key,
    this.targetType =
        FinancialTargetType.expenseBudget,
    this.month,
  });

  @override
  Widget build(
    BuildContext context,
    WidgetRef ref,
  ) {
    final selectedMonth =
        month ?? DateTime.now();

    final isExpenseBudget =
        targetType ==
            FinancialTargetType
                .expenseBudget;

    final params = (
      targetType: targetType,
      year: selectedMonth.year,
      month: selectedMonth.month,
    );

    final alertsAsync = ref.watch(
      financialTargetAlertsProvider(
        params,
      ),
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(
          isExpenseBudget
              ? 'Budget Alerts'
              : 'Income Targets',
        ),
      ),
      body: alertsAsync.when(
        data: (alerts) {
          if (alerts.isEmpty) {
            return Center(
              child: Text(
                isExpenseBudget
                    ? 'No budget alerts for selected month'
                    : 'No income targets for selected month',
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(
                financialTargetAlertsProvider(
                  params,
                ),
              );

              await ref.read(
                financialTargetAlertsProvider(
                  params,
                ).future,
              );
            },
            child:
                SingleChildScrollView(
              physics:
                  const AlwaysScrollableScrollPhysics(),
              padding:
                  const EdgeInsets.fromLTRB(
                16,
                16,
                16,
                40,
              ),
              child:
                  BudgetAlertsSection(
                alerts: alerts,
                targetType: targetType,
              ),
            ),
          );
        },
        error: (_, __) =>
            Center(
          child: Text(
            isExpenseBudget
                ? 'Unable to load budget alerts'
                : 'Unable to load income targets',
          ),
        ),
        loading: () =>
            const Center(
          child:
              CircularProgressIndicator(),
        ),
      ),
    );
  }
}