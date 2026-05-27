import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/utils/currency_formatter.dart';

import '../../domain/models/budget_alert_model.dart';
import '../../../../shared/providers/currency_provider.dart';

class BudgetAlertsSection
    extends ConsumerWidget {

  final List<BudgetAlertModel>
      alerts;

  const BudgetAlertsSection({
    super.key,
    required this.alerts,
  });

  @override
  Widget build(
    BuildContext context,
    WidgetRef ref,
  ) {

    if (alerts.isEmpty) {

      return const SizedBox();
    }

    final currency =
        ref.watch(
      currencyProvider,
    );

    return Column(

      crossAxisAlignment:
          CrossAxisAlignment.start,

      children: [

        const Text(

          'Budget Alerts',

          style: TextStyle(

            fontSize: 18,

            fontWeight:
                FontWeight.bold,
          ),
        ),

        const SizedBox(
          height: 16,
        ),

        ...alerts.map((alert) {

          IconData icon;

          Color color;

          String title;

          if (alert.type ==
              BudgetAlertType
                  .exceeded) {

            icon =
                Icons.error;

            color =
                Colors.red;

            title =
                'Budget exceeded';

          } else if (alert.type ==
              BudgetAlertType
                  .warning) {

            icon =
                Icons.warning;

            color =
                Colors.orange;

            title =
                'Budget nearing limit';

          } else {

            icon =
                Icons.check_circle;

            color =
                Colors.green;

            title =
                'Budget healthy';
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

                    '${CurrencyFormatter.formatDouble(
                      amount: alert.spent,
                      currency: currency,
                    )} / ${CurrencyFormatter.formatDouble(
                      amount: alert.budget,
                      currency: currency,
                    )}',
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
        }),
      ],
    );
  }
}
