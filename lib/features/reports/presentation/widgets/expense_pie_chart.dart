import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
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

    return Column(

      crossAxisAlignment:
          CrossAxisAlignment.start,


      children: [
        
        const Text(

          'Expense Breakdown',

          style: TextStyle(
            fontSize: 18,
            fontWeight:
                FontWeight.bold,
          ),
        ),

        const SizedBox(height: 4),

        const Text(

          'See where your money goes in Visual presentation',

          style: TextStyle(
            color: Colors.grey,
          ),
        ),
        const SizedBox(
          height: 16,
        ),

        SizedBox(

          height: 300,

          child: Stack(

            alignment:
                Alignment.center,

            children: [
                PieChart(

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
            ],
          ),
        ),

        const SizedBox(
          height: 16,
        ),
      ]
    );
  }
}