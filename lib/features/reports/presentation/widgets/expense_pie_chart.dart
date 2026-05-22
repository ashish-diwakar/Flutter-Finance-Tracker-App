import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

//import '../../../../core/utils/currency_formatter.dart';
import '../../domain/models/category_expense_model.dart';

class ExpensePieChart
    extends StatelessWidget {

  final List<CategoryExpenseModel>
      categories;
  final List<Color> colors; // Add this line
  final List<Color> forecolors; // Add this line

  const ExpensePieChart({
    super.key,
    required this.categories,
    required this.colors, // Add this line
    required this.forecolors, // Add this line
  });

  @override
  Widget build(BuildContext context) {

    if (categories.isEmpty) {

      return const Center(
        child: Text('No Expense Data'),
      );
    }

    return SizedBox(

      height: 250,

      child: PieChart(

        PieChartData(

          sections: categories
              .asMap()
              .entries
              .map((entry) {

            final item = entry.value;

            return PieChartSectionData(
              value:
                  item.amount.toDouble(),

              title:
                  item.category,

              radius: 80,
              color: colors[entry.key % colors.length], // Use the color from the list
              titleStyle: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: forecolors[entry.key % forecolors.length], // Use the foreground color from the list
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}