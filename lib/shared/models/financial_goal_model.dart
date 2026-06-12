import 'package:isar_community/isar.dart';

part 'financial_goal_model.g.dart';

@collection
class FinancialGoalModel {

  Id id = Isar.autoIncrement;

  @Index(unique: true)
  late String uuid;

  // ==========================================
  // BASIC INFO
  // ==========================================

  late String name;

  String? description;

  // ==========================================
  // GOAL VALUES
  // ==========================================

  late int targetAmount;

  int currentAmount = 0;

  // ==========================================
  // LINKED ACCOUNT
  // ==========================================

  String? linkedAccountId;

  // ==========================================
  // DATES
  // ==========================================

  DateTime? targetDate;

  DateTime createdAt =
      DateTime.now().toUtc();

  DateTime updatedAt =
      DateTime.now().toUtc();

  // ==========================================
  // STATUS
  // ==========================================

  bool isCompleted = false;

  // ==========================================
  // SYNC
  // ==========================================

  bool isDeleted = false;

  bool isSynced = false;

  Map<String, dynamic> toJson() {

    return {

      'id': uuid,

      'name': name,

      'description': description,

      'targetAmount': targetAmount,

      'currentAmount': currentAmount,

      'linkedAccountId': linkedAccountId,

      'targetDate':
          targetDate?.toIso8601String(),

      'isCompleted':
          isCompleted,

      'createdAt':
          createdAt.toIso8601String(),

      'updatedAt':
          updatedAt.toIso8601String(),

      'isDeleted':
          isDeleted,
    };
  }
}