import 'package:isar_community/isar.dart';

import '../../../../shared/models/financial_goal_model.dart';
import '../../domain/models/goal_analytics_model.dart';

class GoalAnalyticsService {

  final Isar isar;

  GoalAnalyticsService(
    this.isar,
  );

  Future<GoalAnalyticsModel>
      calculateAnalytics()
  async {

    final goals =
        await isar
            .financialGoalModels
            .filter()
            .isDeletedEqualTo(
              false,
            )
            .findAll();

    if (goals.isEmpty) {

      return const GoalAnalyticsModel(

        totalGoals: 0,

        completedGoals: 0,

        averageProgress: 0,

        totalTargetAmount: 0,

        totalSavedAmount: 0,

        remainingAmount: 0,
      );
    }

    int completedGoals = 0;

    int totalTargetAmount = 0;

    int totalSavedAmount = 0;

    double progressTotal = 0;

    for (final goal in goals) {

      totalTargetAmount +=
          goal.targetAmount;

      totalSavedAmount +=
          goal.currentAmount;

      if (goal.isCompleted) {

        completedGoals++;
      }

      if (goal.targetAmount > 0) {

        progressTotal +=

            (goal.currentAmount /
                    goal.targetAmount)
                .clamp(
                  0,
                  1,
                );
      }
    }

    final averageProgress =

        (progressTotal /
                goals.length) *
            100;

    final remainingAmount =

        totalTargetAmount -
            totalSavedAmount;

    return GoalAnalyticsModel(

      totalGoals:
          goals.length,

      completedGoals:
          completedGoals,

      averageProgress:
          averageProgress,

      totalTargetAmount:
          totalTargetAmount,

      totalSavedAmount:
          totalSavedAmount,

      remainingAmount:
          remainingAmount < 0
              ? 0
              : remainingAmount,
    );
  }
}