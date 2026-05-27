import 'package:flutter/material.dart';

import '../../domain/models/financial_insight_model.dart';

class FinancialInsightsSection
    extends StatelessWidget {

  final List<
      FinancialInsightModel>
      insights;

  const FinancialInsightsSection({
    super.key,
    required this.insights,
  });

  IconData getIcon(
    String type,
  ) {

    switch (type) {

      case 'warning':
        return Icons.warning_amber;

      case 'success':
        return Icons.check_circle;

      case 'tip':
        return Icons.lightbulb;

      default:
        return Icons.insights;
    }
  }

  @override
  Widget build(
    BuildContext context,
  ) {

    if (insights.isEmpty) {

      return const SizedBox();
    }

    return Column(

      crossAxisAlignment:
          CrossAxisAlignment.start,

      children: [

        const Text(

          'AI Financial Insights',

          style: TextStyle(

            fontSize: 20,

            fontWeight:
                FontWeight.bold,
          ),
        ),

        const SizedBox(
          height: 6,
        ),

        const Text(

          'Personalized intelligence based on your spending behavior.',

          style: TextStyle(
            color: Colors.grey,
          ),
        ),

        const SizedBox(
          height: 16,
        ),

        ...insights.map(

          (insight) {

            return Card(

              child: ListTile(

                leading: Icon(
                  getIcon(
                    insight.type,
                  ),
                ),

                title: Text(
                  insight.title,
                ),

                subtitle: Text(
                  insight.description,
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}