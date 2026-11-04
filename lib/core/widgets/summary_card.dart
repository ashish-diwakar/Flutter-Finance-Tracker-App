
import 'package:flutter/material.dart';

enum SummaryCardVariant {
  standard,
  income,
  expense,
}

class SummaryCard extends StatelessWidget {
  final String title;
  final String amount;
  final IconData icon;
  final SummaryCardVariant variant;

  const SummaryCard({
    super.key,
    required this.title,
    required this.amount,
    required this.icon,
    this.variant = SummaryCardVariant.standard,
  });

  @override
  Widget build(BuildContext context) {
    // Preserve the existing appearance for
    // other screens using SummaryCard.
    if (variant == SummaryCardVariant.standard) {
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

    final isIncome =
        variant == SummaryCardVariant.income;

    final accentColor = isIncome
        ? const Color(0xFF075E41)
        : const Color(0xFFA73543);

    final gradientColors = isIncome
        ? const [
            Color(0xFFE4FFF0),
            Color(0xFFB4EACD),
            Color(0xFF81CAA9),
          ]
        : const [
            Color(0xFFFFECEB),
            Color(0xFFFFD0CD),
            Color(0xFFF6AAA8),
          ];

    return Container(
      constraints: const BoxConstraints(
        minHeight: 104,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: gradientColors,
        ),
        border: Border.all(
          color: Colors.white.withValues(
            alpha: 0.75,
          ),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: accentColor.withValues(
              alpha: 0.18,
            ),
            blurRadius: 16,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: Stack(
          children: [
            // Soft reflective highlight.
            Positioned(
              top: -35,
              right: -25,
              child: Container(
                width: 105,
                height: 105,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      Color(0xCCFFFFFF),
                      Color(0x00FFFFFF),
                    ],
                  ),
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 12,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withValues(
                            alpha: 0.50,
                          ),
                        ),
                        child: Icon(
                          icon,
                          size: 19,
                          color: accentColor,
                        ),
                      ),
                      const SizedBox(width: 7),
                      Expanded(
                        child: Text(
                          title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: accentColor,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  SizedBox(
                    width: double.infinity,
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: Text(
                        amount,
                        maxLines: 1,
                        style: TextStyle(
                          fontSize: 21,
                          fontWeight: FontWeight.w800,
                          color: accentColor,
                          letterSpacing: -0.5,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
