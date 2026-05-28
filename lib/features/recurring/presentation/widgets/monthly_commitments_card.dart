import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/utils/currency_formatter.dart';
import '../../../../shared/providers/currency_provider.dart';

import '../../domain/models/recurring_analytics_model.dart';

class MonthlyCommitmentsCard
    extends ConsumerWidget {

  final RecurringAnalyticsModel
      analytics;

  const MonthlyCommitmentsCard({

    super.key,

    required this.analytics,
  });

  @override
  Widget build(
    BuildContext context,
    WidgetRef ref,
  ) {

    final currency =
        ref.watch(
      currencyProvider,
    );

    return Card(

      child: Padding(

        padding:
            const EdgeInsets.all(
          20,
        ),

        child: Column(

          crossAxisAlignment:
              CrossAxisAlignment
                  .start,

          children: [

            const Row(

              children: [

                Icon(
                  Icons.repeat,
                ),

                SizedBox(
                  width: 8,
                ),

                Text(

                  'Monthly Commitments',

                  style: TextStyle(

                    fontSize: 20,

                    fontWeight:
                        FontWeight.bold,
                  ),
                ),
              ],
            ),

            const SizedBox(
              height: 20,
            ),

            Text(

              CurrencyFormatter
                  .formatDouble(

                amount:
                    analytics
                        .monthlyRecurringExpense,

                currency:
                    currency,
              ),

              style:
                  const TextStyle(

                fontSize: 32,

                fontWeight:
                    FontWeight.bold,
              ),
            ),

            const SizedBox(
              height: 8,
            ),

            Text(

              '${analytics.recurringIncomeRatio.toStringAsFixed(0)}%'
              ' of monthly income',

              style:
                  const TextStyle(

                color: Colors.grey,
              ),
            ),

            const SizedBox(
              height: 20,
            ),

            Row(

              mainAxisAlignment:
                  MainAxisAlignment
                      .spaceBetween,

              children: [

                _metric(

                  'Active',

                  analytics
                      .activeRecurringCount
                      .toString(),
                ),

                _metric(

                  'Top Category',

                  analytics
                          .topRecurringCategory ??
                      'N/A',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _metric(
    String title,
    String value,
  ) {

    return Column(

      crossAxisAlignment:
          CrossAxisAlignment.start,

      children: [

        Text(

          value,

          style:
              const TextStyle(

            fontWeight:
                FontWeight.bold,

            fontSize: 18,
          ),
        ),

        const SizedBox(
          height: 4,
        ),

        Text(
          title,
        ),
      ],
    );
  }
}