import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/utils/currency_formatter.dart';
import '../../../../shared/providers/currency_provider.dart';

import '../../domain/models/recurring_analytics_model.dart';

class MonthlyCommitmentsCard extends ConsumerWidget {
  final RecurringAnalyticsModel analytics;

  const MonthlyCommitmentsCard({super.key, required this.analytics});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currency = ref.watch(currencyProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,

      children: [
        Text(
          CurrencyFormatter.formatDouble(
            amount: analytics.monthlyRecurringExpense,

            currency: currency,
          ),

          style: const TextStyle(
            color: Color(0xFF244C40),
            fontSize: 26,

            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: 8),

        Text(
          '${analytics.recurringIncomeRatio.toStringAsFixed(0)}%'
          ' of monthly income',

          style: const TextStyle(
            color: Color(0xFF536B61),
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),

        const SizedBox(height: 20),

        Row(
          children: [
            Expanded(
              child: _metric(
                'Active',
                analytics.activeRecurringCount.toString(),
              ),
            ),

            const SizedBox(width: 12),
            Expanded(
              child: _metric(
                'Top Category',
                analytics.topRecurringCategory ?? 'N/A',
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _metric(String title, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,

      children: [
        Text(
          value,

          style: const TextStyle(
            color: Color(0xFF244C40),
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),

        const SizedBox(height: 4),

        Text(
          title,
          style: const TextStyle(
            color: Color(0xFF536B61),
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
