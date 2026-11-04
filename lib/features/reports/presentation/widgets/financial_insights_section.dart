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

        ...insights.map(

          (insight) {

            return Card(
              color: const Color(0xCCFFFFFF),
              elevation: 0,
              margin: const EdgeInsets.only(bottom: 8),

              child: ListTile(

                leading: Icon(
                  getIcon(
                    insight.type,
                  ),
                ),

                title: Text(
                  insight.title,
                  style: const TextStyle(
                    color: Color(0xFF244C40),
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),

                subtitle: Text(
                  insight.description,
                  style: const TextStyle(
                    color: Color(0xFF536B61),
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
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