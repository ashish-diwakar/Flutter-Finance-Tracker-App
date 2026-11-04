import 'package:flutter/material.dart';

import '../../domain/models/financial_health_model.dart';

class FinancialHealthCard
    extends StatelessWidget {

  final FinancialHealthModel
      health;

  const FinancialHealthCard({

    super.key,

    required this.health,
  });

  Color getScoreColor() {

    if (health.score >=
        85) {

      return Colors.green;
    }

    if (health.score >=
        70) {

      return Colors.lightGreen;
    }

    if (health.score >=
        55) {

      return Colors.orange;
    }

    if (health.score >=
        40) {

      return Colors.deepOrange;
    }

    return Colors.red;
  }

  @override
  Widget build(
    BuildContext context,
  ) {

    final color =
        getScoreColor();

    return Column(

          children: [

            Container(

              width: 120,

              height: 120,

              decoration:
                  BoxDecoration(

                shape:
                    BoxShape.circle,

                border: Border.all(

                  color: color,

                  width: 10,
                ),
              ),

              alignment:
                  Alignment.center,

              child: Column(

                mainAxisAlignment:
                    MainAxisAlignment
                        .center,

                children: [

                  Text(

                    health.score
                        .toStringAsFixed(
                      0,
                    ),

                    style:
                        TextStyle(

                      fontSize: 28,

                      fontWeight:
                          FontWeight
                              .bold,

                      color: color,
                    ),
                  ),

                  const Text(
                    '/100',
                  ),
                ],
              ),
            ),

            const SizedBox(
              height: 20,
            ),

            Text(

              health.label,

              style: TextStyle(

                fontSize: 18,
                fontWeight: FontWeight.w600,

                color: color,
              ),
            ),

            const SizedBox(
              height: 10,
            ),

            Text(

              health.description,

              textAlign:
                  TextAlign.center,

              style:
                  const TextStyle(
                color: Color(0xFF536B61),
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),

            const SizedBox(
              height: 24,
            ),

            Row(
              children: [

                Expanded(
                  child: _metric(
                    'Savings',
                    '${health.savingsRate.toStringAsFixed(0)}%',
                  ),
                ),

                Expanded(
                  child: _metric(
                    'Expense',
                    '${health.expenseRatio.toStringAsFixed(0)}%',
                  ),
                ),

                Expanded(
                  child: _metric(
                    'Budget',
                    '${health.budgetUsage.toStringAsFixed(0)}%',
                  ),
                ),
              ],
            ),
          ],
    );
  }

  Widget _metric(
    String title,
    String value,
  ) {

    return Column(

      children: [

        Text(

          value,

          style:
              const TextStyle(

            color: Color(0xFF244C40),
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),

        const SizedBox(
          height: 4,
        ),

        Text(
          title,
          textAlign: TextAlign.center,
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