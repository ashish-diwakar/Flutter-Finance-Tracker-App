import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/utils/currency_formatter.dart';
import '../../../../shared/providers/currency_provider.dart';

import '../../data/services/budget_alert_checker.dart';
import '../../domain/models/budget_alert_model.dart';

class BudgetAlertsSection extends ConsumerWidget {
  final List<BudgetAlertModel> alerts;

  final FinancialTargetType targetType;

  const BudgetAlertsSection({
    super.key,
    required this.alerts,
    this.targetType = FinancialTargetType.expenseBudget,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (alerts.isEmpty) {
      return const SizedBox();
    }

    final currency = ref.watch(currencyProvider);

    final isExpenseBudget = targetType == FinancialTargetType.expenseBudget;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ...alerts.map((alert) {
          IconData icon;
          Color color;
          Color statusBackground;
          String title;

          if (isExpenseBudget) {
            // =================================
            // EXPENSE BUDGET
            // Higher percentage = worse
            // =================================

            if (alert.type == BudgetAlertType.exceeded) {
              icon = Icons.error;
              color = const Color(0xFFB54C44);
              statusBackground = const Color(0xFFFBE8E3);
              title = 'Budget exceeded';
            } else if (alert.type == BudgetAlertType.warning) {
              icon = Icons.warning;
              color = const Color(0xFF9A6700);
              statusBackground = const Color(0xFFFFF1D6);
              title = 'Budget nearing limit';
            } else {
              icon = Icons.check_circle;
              color = const Color(0xFF237F50);
              statusBackground = const Color(0xFFDFF1E5);
              title = 'Budget healthy';
            }
          } else {
            // =================================
            // INCOME TARGET
            // Higher percentage = better
            // =================================

            if (alert.percentage >= 1) {
              icon = Icons.check_circle;
              color = const Color(0xFF237F50);
              statusBackground = const Color(0xFFDFF1E5);

              title = alert.percentage > 1
                  ? 'Target exceeded'
                  : 'Target reached';
            } else if (alert.percentage >= 0.8) {
              icon = Icons.trending_up;
              color = const Color(0xFF9A6700);
              statusBackground = const Color(0xFFFFF1D6);
              title = 'Approaching target';
            } else {
              icon = Icons.trending_down;
              color = const Color(0xFFB54C44);
              statusBackground = const Color(0xFFFBE8E3);
              title = 'Behind target';
            }
          }

          final spentLabel = CurrencyFormatter.formatDouble(
            amount: alert.spent,
            currency: currency,
          );
          final budgetLabel = CurrencyFormatter.formatDouble(
            amount: alert.budget,
            currency: currency,
          );
          final hasUtilization = alert.budget > 0 && alert.percentage.isFinite;
          final progress = hasUtilization
              ? alert.percentage.clamp(0.0, 1.0).toDouble()
              : 0.0;
          final percentageLabel = hasUtilization
              ? '${(alert.percentage * 100).toStringAsFixed(0)}%'
              : '—';

          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            color: const Color(0xFFF0F8F2),
            surfaceTintColor: Colors.transparent,
            elevation: 1,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
              side: const BorderSide(color: Color(0xFFB8D8CA)),
            ),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    alert.category,
                    style: const TextStyle(
                      color: Color(0xFF244D40),
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: statusBackground,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(icon, color: color, size: 18),
                            const SizedBox(width: 6),
                            Text(
                              title,
                              style: TextStyle(
                                color: color,
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: statusBackground,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          percentageLabel,
                          style: TextStyle(
                            color: color,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  _BudgetAlertValueRow(
                    label: isExpenseBudget ? 'Spent' : 'Received',
                    value: spentLabel,
                  ),
                  const SizedBox(height: 8),
                  _BudgetAlertValueRow(
                    label: isExpenseBudget ? 'Budget' : 'Target',
                    value: budgetLabel,
                  ),
                  const SizedBox(height: 12),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(5),
                    child: LinearProgressIndicator(
                      value: progress,
                      minHeight: 9,
                      backgroundColor: const Color(0xFFDDEBE2),
                      valueColor: AlwaysStoppedAnimation<Color>(color),
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }
}

class _BudgetAlertValueRow extends StatelessWidget {
  final String label;
  final String value;

  const _BudgetAlertValueRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Text(
            label,
            style: const TextStyle(color: Color(0xFF536B61), fontSize: 14),
          ),
        ),
        const SizedBox(width: 12),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: const TextStyle(
              color: Color(0xFF244D40),
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}
