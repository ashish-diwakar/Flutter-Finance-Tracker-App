
import 'package:flutter/material.dart';

import '../../domain/models/finance_insight_model.dart';

class DashboardInsightsSection extends StatelessWidget {
  final List<FinanceInsightModel> insights;

  const DashboardInsightsSection({
    super.key,
    required this.insights,
  });

  @override
  Widget build(BuildContext context) {
    if (insights.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Smart Insights',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),

        const SizedBox(height: 10),

        ...insights.map((insight) {
          Color accentColor;
          IconData icon;
          List<Color> gradientColors;

          switch (insight.type) {
            case FinanceInsightType.success:
              accentColor = const Color(0xFF08744F);
              icon = Icons.check_circle_rounded;
              gradientColors = [
                const Color(0xFFD7F6E6),
                const Color(0xFFF5FFF9),
              ];
              break;

            case FinanceInsightType.warning:
              accentColor = const Color(0xFFAD6700);
              icon = Icons.warning_amber_rounded;
              gradientColors = [
                const Color(0xFFFFE5B6),
                const Color(0xFFFFF9EC),
              ];
              break;

            case FinanceInsightType.danger:
              accentColor = const Color(0xFFB72C39);
              icon = Icons.error_outline_rounded;
              gradientColors = [
                const Color(0xFFFFD5D9),
                const Color(0xFFFFF4F4),
              ];
              break;

            default:
              accentColor = const Color(0xFF1769B1);
              icon = Icons.info_outline_rounded;
              gradientColors = [
                const Color(0xFFD8EAFF),
                const Color(0xFFF6FAFF),
              ];
          }

          return Container(
            width: double.infinity,
            margin: const EdgeInsets.only(
              bottom: 8,
            ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: gradientColors,
              ),
              border: Border.all(
                color: Colors.white.withValues(
                  alpha: 0.85,
                ),
                width: 1.1,
              ),
              boxShadow: [
                BoxShadow(
                  color: accentColor.withValues(
                    alpha: 0.10,
                  ),
                  blurRadius: 12,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Stack(
                children: [
                  // Soft ambient reflection.
                  Positioned(
                    top: -35,
                    right: -20,
                    child: Container(
                      width: 110,
                      height: 110,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            Color(0x99FFFFFF),
                            Color(0x00FFFFFF),
                          ],
                        ),
                      ),
                    ),
                  ),

                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 11,
                    ),
                    child: Row(
                      crossAxisAlignment:
                          CrossAxisAlignment.center,
                      children: [
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            borderRadius:
                                BorderRadius.circular(12),
                            color: Colors.white.withValues(
                              alpha: 0.65,
                            ),
                          ),
                          child: Icon(
                            icon,
                            color: accentColor,
                            size: 21,
                          ),
                        ),

                        const SizedBox(width: 10),

                        Expanded(
                          child: Column(
                            crossAxisAlignment:
                                CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                insight.title,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF23332F),
                                ),
                              ),

                              const SizedBox(height: 3),

                              Text(
                                insight.description,
                                style: const TextStyle(
                                  fontSize: 12,
                                  height: 1.3,
                                  color: Color(0xFF435852),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
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
