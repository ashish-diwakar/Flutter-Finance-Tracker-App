import 'package:flutter/material.dart';

class SummaryCard extends StatelessWidget {

  final String title;
  final String amount;
  final IconData icon;

  const SummaryCard({
    super.key,
    required this.title,
    required this.amount,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {

    return Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [

              Icon(icon),

              const SizedBox(height: 12),

              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 8),

              Text(
                amount,
                style: const TextStyle(
                  fontSize: 18,
                ),
              ),
            ],
          ),
        ),
      );
  }
}