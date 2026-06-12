import 'package:isar_community/isar.dart';
import 'package:uuid/uuid.dart';

import '../../../../shared/models/financial_goal_model.dart';

class GoalRepository {

  final Isar isar;

  GoalRepository(
    this.isar,
  );

  Future<List<FinancialGoalModel>>
      getGoals() {

    return isar
        .financialGoalModels
        .filter()
        .isDeletedEqualTo(false)
        .findAll();
  }

  Future<void> addGoal(
    FinancialGoalModel goal,
  ) async {

    goal.uuid =
        const Uuid().v4();

    goal.updatedAt =
        DateTime.now().toUtc();

    goal.isSynced =
        false;

    await isar.writeTxn(() async {

      await isar
          .financialGoalModels
          .put(goal);
    });
  }

  Future<void> updateGoal(
    FinancialGoalModel goal,
  ) async {

    goal.updatedAt =
        DateTime.now().toUtc();

    goal.isSynced =
        false;

    await isar.writeTxn(() async {

      await isar
          .financialGoalModels
          .put(goal);
    });
  }

  Future<void> deleteGoal(
    FinancialGoalModel goal,
  ) async {

    goal.isDeleted = true;

    goal.isSynced = false;

    goal.updatedAt =
        DateTime.now().toUtc();

    await isar.writeTxn(() async {

      await isar
          .financialGoalModels
          .put(goal);
    });
  }
}