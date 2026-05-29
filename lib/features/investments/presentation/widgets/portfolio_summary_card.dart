import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/utils/currency_formatter.dart';
import '../../../../shared/providers/currency_provider.dart';

import '../../domain/models/investment_analytics_model.dart';

class PortfolioSummaryCard
    extends ConsumerWidget {

  final InvestmentAnalyticsModel
      analytics;

  const PortfolioSummaryCard({

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

    final isProfit =
        analytics.profitLoss >= 0;

    return Card(

      child: Padding(

        padding:
            const EdgeInsets.all(
          20,
        ),

        child: Column(

          crossAxisAlignment:
              CrossAxisAlignment.start,

          children: [

            const Text(

              'Portfolio Overview',

              style: TextStyle(

                fontSize: 20,

                fontWeight:
                    FontWeight.bold,
              ),
            ),

            const SizedBox(
              height: 20,
            ),

            _metric(

              'Current Value',

              CurrencyFormatter.formatDouble(

                amount:
                    analytics.currentValue,

                currency:
                    currency,
              ),
            ),

            const SizedBox(
              height: 16,
            ),

            _metric(

              'Invested Amount',

              CurrencyFormatter.formatDouble(

                amount:
                    analytics.totalInvested,

                currency:
                    currency,
              ),
            ),

            const Divider(
              height: 32,
            ),

            Row(

              mainAxisAlignment:
                  MainAxisAlignment
                      .spaceBetween,

              children: [

                Text(

                  'Profit / Loss',

                  style:
                      TextStyle(

                    color: Colors
                        .grey.shade700,
                  ),
                ),

                Text(

                  CurrencyFormatter
                      .formatDouble(

                    amount:
                        analytics
                            .profitLoss,

                    currency:
                        currency,
                  ),

                  style: TextStyle(

                    color:

                        isProfit

                            ? Colors.green

                            : Colors.red,

                    fontWeight:
                        FontWeight.bold,

                    fontSize: 18,
                  ),
                ),
              ],
            ),

            const SizedBox(
              height: 12,
            ),

            Align(

              alignment:
                  Alignment.centerRight,

              child: Text(

                '${analytics.profitPercentage.toStringAsFixed(2)}%',

                style: TextStyle(

                  color:

                      isProfit

                          ? Colors.green

                          : Colors.red,

                  fontWeight:
                      FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _metric(
    String label,
    String value,
  ) {

    return Row(

      mainAxisAlignment:
          MainAxisAlignment
              .spaceBetween,

      children: [

        Text(

          label,

          style:
              TextStyle(

            color:
                Colors.grey.shade700,
          ),
        ),

        Text(

          value,

          style:
              const TextStyle(

            fontWeight:
                FontWeight.bold,

            fontSize: 18,
          ),
        ),
      ],
    );
  }
}