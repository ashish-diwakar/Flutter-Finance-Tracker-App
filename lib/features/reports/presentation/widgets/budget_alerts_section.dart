import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/utils/currency_formatter.dart';
import '../../../../shared/providers/currency_provider.dart';

import '../../data/services/budget_alert_checker.dart';
import '../../domain/models/budget_alert_model.dart';

class BudgetAlertsSection
    extends ConsumerWidget {
  final List<BudgetAlertModel>
      alerts;

  final FinancialTargetType
      targetType;

  const BudgetAlertsSection({
    super.key,
    required this.alerts,
    this.targetType =
        FinancialTargetType.expenseBudget,
  });

  @override
  Widget build(
    BuildContext context,
    WidgetRef ref,
  ) {
    if (alerts.isEmpty) {
      return const SizedBox();
    }

    final currency = ref.watch(
      currencyProvider,
    );

    final isExpenseBudget =
        targetType ==
            FinancialTargetType
                .expenseBudget;

    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        Text(
          isExpenseBudget
              ? 'Budget Alerts'
              : 'Income Targets',
          style: const TextStyle(
            fontSize: 18,
            fontWeight:
                FontWeight.bold,
          ),
        ),
        const SizedBox(
          height: 16,
        ),
        ...alerts.map(
          (alert) {
            IconData icon;
            Color color;
            String title;

            if (isExpenseBudget) {
              // =================================
              // EXPENSE BUDGET
              // Higher percentage = worse
              // =================================

              if (alert.type ==
                  BudgetAlertType
                      .exceeded) {
                icon = Icons.error;
                color = Colors.red;
                title =
                    'Budget exceeded';
              } else if (alert.type ==
                  BudgetAlertType
                      .warning) {
                icon = Icons.warning;
                color =
                    Colors.orange;
                title =
                    'Budget nearing limit';
              } else {
                icon =
                    Icons.check_circle;
                color = Colors.green;
                title =
                    'Budget healthy';
              }
            } else {
              // =================================
              // INCOME TARGET
              // Higher percentage = better
              // =================================

              if (alert.percentage >=
                  1) {
                icon =
                    Icons.check_circle;
                color = Colors.green;

                title =
                    alert.percentage > 1
                        ? 'Target exceeded'
                        : 'Target reached';
              } else if (
                  alert.percentage >=
                      0.8) {
                icon = Icons.trending_up;
                color =
                    Colors.orange;
                title =
                    'Approaching target';
              } else {
                icon =
                    Icons.trending_down;
                color = Colors.red;
                title =
                    'Behind target';
              }
            }

            return Card(
              margin:
                  const EdgeInsets.only(
                bottom: 12,
              ),
              child: ListTile(
                leading: Icon(
                  icon,
                  color: color,
                ),
                title: Text(
                  alert.category,
                ),
                subtitle: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment
                          .start,
                  children: [
                    Text(title),
                    const SizedBox(
                      height: 4,
                    ),
                    Text(
                      isExpenseBudget
                          ? '${CurrencyFormatter.formatDouble(
                              amount:
                                  alert.spent,
                              currency:
                                  currency,
                            )} / ${CurrencyFormatter.formatDouble(
                              amount:
                                  alert.budget,
                              currency:
                                  currency,
                            )}'
                          : '${CurrencyFormatter.formatDouble(
                              amount:
                                  alert.spent,
                              currency:
                                  currency,
                            )} received / ${CurrencyFormatter.formatDouble(
                              amount:
                                  alert.budget,
                              currency:
                                  currency,
                            )} target',
                    ),
                  ],
                ),
                trailing: Text(
                  '${(alert.percentage * 100).toStringAsFixed(0)}%',
                  style: TextStyle(
                    color: color,
                    fontWeight:
                        FontWeight.bold,
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}