import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/utils/currency_formatter.dart';
import '../../domain/models/budget_progress_data.dart';
import '../../../../shared/providers/currency_provider.dart';

class BudgetProgressChart
    extends ConsumerWidget {

  final List<BudgetProgressData>
      data;

  const BudgetProgressChart({
    super.key,
    required this.data,
  });

  @override
  Widget build(
    BuildContext context,
    WidgetRef ref,
  ) {

    if (data.isEmpty) {

      return const Center(
        child: Text(
          'No budget data',
        ),
      );
    }

    final currency =
        ref.watch(
      currencyProvider,
    );

    return Column(

      crossAxisAlignment:
          CrossAxisAlignment.start,

      children: [

        // const Text(

        //   'Budget Progress',

        //   style: TextStyle(

        //     fontSize: 18,

        //     fontWeight:
        //         FontWeight.bold,
        //   ),
        // ),

        // const SizedBox(height: 4),

        // const Text(

        //   'Monitor spending against your limits',

        //   style: TextStyle(
        //     color: Colors.grey,
        //   ),
        // ),

        // const SizedBox(
        //   height: 20,
        // ),

        ...data.map((item) {

          final progress =
              item.progress;

          final percentage =
              (progress * 100)
                  .toStringAsFixed(0);

          Color progressColor;

          Color? progressBorderColor;

          Color? progressBackColor;

          if (progress < 0.3) {

            progressColor =
                Colors.green;

          } else if (progress <
              0.5) {

            progressColor =
                Colors.yellow;

          } else if (progress <
              0.75) {

            progressColor =
                Colors.orange;

          } else {

            progressColor =
                Colors.red;

            progressBackColor =
                const Color.fromARGB(
              255,
              211,
              233,
              191,
            );

            progressBorderColor =
                const Color.fromARGB(
              255,
              235,
              196,
              209,
            );
          }

          return Card(

            color:
                progressBackColor ??
                    Colors.grey.shade50,

            shape:
                RoundedRectangleBorder(

              borderRadius:
                  BorderRadius.circular(
                12,
              ),

              side: BorderSide(

                color:
                    progressBorderColor ??
                        Colors.grey.shade300,

                width: 1,
              ),
            ),

            child: Padding(

              padding:
                  const EdgeInsets.only(

                bottom: 20,
                top: 10,
                right: 10,
                left: 10,
              ),

              child: Column(

                crossAxisAlignment:
                    CrossAxisAlignment
                        .start,

                children: [

                  Row(

                    children: [

                      Expanded(

                        child: Text(

                          item.category,

                          style:
                              const TextStyle(

                            fontWeight:
                                FontWeight.bold,
                          ),
                        ),
                      ),

                      Text(

                        '$percentage%',

                        style:
                            TextStyle(

                          fontWeight:
                              FontWeight.w600,

                          fontStyle:
                              FontStyle.italic,

                          color:

                              (progress < 1.0)

                                  ? Colors.green

                                  : Colors.red,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(
                    height: 8,
                  ),

                  ClipRRect(

                    borderRadius:
                        BorderRadius.circular(
                      8,
                    ),

                    child:
                        LinearProgressIndicator(

                      value:
                          progress,

                      minHeight:
                          10,

                      backgroundColor:
                          Colors.grey.shade300,

                      valueColor:
                          AlwaysStoppedAnimation(
                        progressColor,
                      ),
                    ),
                  ),

                  const SizedBox(
                    height: 6,
                  ),

                  Row(

                    mainAxisAlignment:
                        MainAxisAlignment
                            .spaceBetween,

                    children: [

                      Text(

                        'Spent: '
                        '${CurrencyFormatter.formatDouble(
                          amount: item.spent,
                          currency: currency,
                        )}',

                        style:
                            const TextStyle(
                          fontSize: 12,
                        ),
                      ),

                      Text(

                        'Budget: '
                        '${CurrencyFormatter.formatDouble(
                          amount: item.budget,
                          currency: currency,
                        )}',

                        style:
                            const TextStyle(
                          fontSize: 12,
                        ),
                      ),
                    ],
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
