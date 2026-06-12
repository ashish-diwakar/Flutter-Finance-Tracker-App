import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/utils/currency_formatter.dart';
import '../../../../shared/providers/currency_provider.dart';
import '../providers/goal_analytics_provider.dart';

class GoalsSummaryCard
    extends ConsumerWidget {

  const GoalsSummaryCard({
    super.key,
  });

  @override
  Widget build(
    BuildContext context,
    WidgetRef ref,
  ) {

    final analytics =
        ref.watch(
      goalAnalyticsProvider,
    );

    final currency =
        ref.watch(
      currencyProvider,
    );

    return analytics.when(

      loading:
          () => const Card(

        child: Padding(

          padding:
              EdgeInsets.all(
            16,
          ),

          child: Center(
            child:
                CircularProgressIndicator(),
          ),
        ),
      ),

      error:
          (e, _) => Card(

        child: Padding(

          padding:
              const EdgeInsets.all(
            16,
          ),

          child: Text(
            e.toString(),
          ),
        ),
      ),

      data: (data) {

        return Card(

          child: Padding(

            padding:
                const EdgeInsets.all(
              16,
            ),

            child: Column(

              crossAxisAlignment:
                  CrossAxisAlignment.start,

              children: [

                const Row(

                  children: [

                    Icon(
                      Icons.flag,
                    ),

                    SizedBox(
                      width: 8,
                    ),

                    Text(

                      'Financial Goals',

                      style: TextStyle(

                        fontSize: 18,

                        fontWeight:
                            FontWeight.bold,
                      ),
                    ),
                  ],
                ),

                const SizedBox(
                  height: 16,
                ),

                Text(
                  'Goals: ${data.totalGoals}',
                ),

                Text(
                  'Completed: ${data.completedGoals}',
                ),

                Text(
                  'Progress: ${data.averageProgress.toStringAsFixed(0)}%',
                ),

                const Divider(),

                Text(

                  'Saved: ${CurrencyFormatter.format(

                    amount:
                        data.totalSavedAmount,

                    currency:
                        currency,
                  )}',
                ),

                Text(

                  'Target: ${CurrencyFormatter.format(

                    amount:
                        data.totalTargetAmount,

                    currency:
                        currency,
                  )}',
                ),

                Text(

                  'Remaining: ${CurrencyFormatter.format(

                    amount:
                        data.remainingAmount,

                    currency:
                        currency,
                  )}',
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}