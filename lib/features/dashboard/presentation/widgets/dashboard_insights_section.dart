import 'package:flutter/material.dart';

import '../../domain/models/finance_insight_model.dart';

class DashboardInsightsSection
    extends StatelessWidget {

  final List<
      FinanceInsightModel>
      insights;

  const DashboardInsightsSection({
    super.key,
    required this.insights,
  });

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

          'Smart Insights',

          style: TextStyle(

            fontSize: 18,

            fontWeight:
                FontWeight.bold,
          ),
        ),

        const SizedBox(
          height: 16,
        ),

        ...insights.map(
          (insight) {

            Color color;

            IconData icon;

            switch (
                insight.type) {

              case FinanceInsightType
                    .success:

                color =
                    Colors.green;

                icon =
                    Icons.check_circle;

                break;

              case FinanceInsightType
                    .warning:

                color =
                    Colors.orange;

                icon =
                    Icons.warning;

                break;

              case FinanceInsightType
                    .danger:

                color =
                    Colors.red;

                icon =
                    Icons.error;

                break;

              default:

                color =
                    Colors.blue;

                icon =
                    Icons.info;
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