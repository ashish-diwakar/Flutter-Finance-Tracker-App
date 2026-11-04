
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/utils/currency_formatter.dart';
import '../../../../shared/providers/currency_provider.dart';
import '../providers/goal_analytics_provider.dart';

class GoalsSummaryCard extends ConsumerWidget {
  final bool auroraStyle;

  const GoalsSummaryCard({
    super.key,
    this.auroraStyle = false,
  });

  @override
  Widget build(
    BuildContext context,
    WidgetRef ref,
  ) {
    final analytics = ref.watch(
      goalAnalyticsProvider,
    );

    final currency = ref.watch(
      currencyProvider,
    );

    return analytics.when(
      loading: () => const Card(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Center(
            child: CircularProgressIndicator(),
          ),
        ),
      ),
      error: (e, _) => Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Text(e.toString()),
        ),
      ),
      data: (data) {
        // Preserve original styling outside Dashboard.
        if (!auroraStyle) {
          return Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.flag),
                      SizedBox(width: 8),
                      Text(
                        'Financial Goals',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text('Goals: ${data.totalGoals}'),
                  Text(
                    'Completed: ${data.completedGoals}',
                  ),
                  Text(
                    'Progress: ${data.averageProgress.toStringAsFixed(0)}%',
                  ),
                  const Divider(),
                  Text(
                    'Saved: ${CurrencyFormatter.format(
                      amount: data.totalSavedAmount,
                      currency: currency,
                    )}',
                  ),
                  Text(
                    'Target: ${CurrencyFormatter.format(
                      amount: data.totalTargetAmount,
                      currency: currency,
                    )}',
                  ),
                  Text(
                    'Remaining: ${CurrencyFormatter.format(
                      amount: data.remainingAmount,
                      currency: currency,
                    )}',
                  ),
                ],
              ),
            ),
          );
        }

        final progress =
            data.averageProgress
                .clamp(0.0, 100.0)
                .toDouble() /
            100;

        final progressText =
            data.averageProgress.toStringAsFixed(0);

        final savedText = CurrencyFormatter.format(
          amount: data.totalSavedAmount,
          currency: currency,
        );

        final targetText = CurrencyFormatter.format(
          amount: data.totalTargetAmount,
          currency: currency,
        );

        final remainingText = CurrencyFormatter.format(
          amount: data.remainingAmount,
          currency: currency,
        );

        const accentColor = Color(0xFF08785C);

        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFFFFFFFF),
                Color(0xFFE6F9EF),
                Color(0xFFBFE9DA),
              ],
              stops: [0.0, 0.55, 1.0],
            ),
            border: Border.all(
              color: Colors.white.withValues(
                alpha: 0.85,
              ),
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: accentColor.withValues(
                  alpha: 0.13,
                ),
                blurRadius: 14,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(18),
            child: Stack(
              children: [
                // Decorative ambient glow.
                Positioned(
                  top: -55,
                  right: -35,
                  child: Container(
                    width: 150,
                    height: 150,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          Color(0xA6FFFFFF),
                          Color(0x00FFFFFF),
                        ],
                      ),
                    ),
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.all(12),
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
                                alpha: 0.65,
                              ),
                            ),
                            child: const Icon(
                              Icons.flag_outlined,
                              size: 20,
                              color: accentColor,
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Expanded(
                            child: Text(
                              'Financial Goals',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF164D3F),
                              ),
                            ),
                          ),
                          Container(
                            padding:
                                const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 5,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFC6EFDD),
                              borderRadius:
                                  BorderRadius.circular(20),
                            ),
                            child: Text(
                              '$progressText%',
                              style: const TextStyle(
                                color: accentColor,
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 12),

                      // Luminous progress indicator.
                      Semantics(
                        label:
                            'Financial goals progress $progressText percent',
                        child: Container(
                          height: 8,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: const Color(0xFFCAE4D9),
                            borderRadius:
                                BorderRadius.circular(8),
                          ),
                          child: ClipRRect(
                            borderRadius:
                                BorderRadius.circular(8),
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: FractionallySizedBox(
                                widthFactor: progress,
                                child: Container(
                                  decoration:
                                      const BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        Color(0xFF08785C),
                                        Color(0xFF22BE8F),
                                        Color(0xFF77E2B5),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 12),

                      Row(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: _GoalAmountMetric(
                              label: 'Saved',
                              amount: savedText,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: _GoalAmountMetric(
                              label: 'Target',
                              amount: targetText,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: _GoalAmountMetric(
                              label: 'Remaining',
                              amount: remainingText,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 8),

                      Text(
                        'Goals: ${data.totalGoals}  •  '
                        'Completed: ${data.completedGoals}',
                        style: const TextStyle(
                          fontSize: 11,
                          color: Color(0xFF52796B),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _GoalAmountMetric extends StatelessWidget {
  final String label;
  final String amount;

  const _GoalAmountMetric({
    required this.label,
    required this.amount,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            color: Color(0xFF52796B),
          ),
        ),
        const SizedBox(height: 3),
        SizedBox(
          width: double.infinity,
          height: 22,
          child: FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              amount,
              maxLines: 1,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: Color(0xFF164D3F),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
