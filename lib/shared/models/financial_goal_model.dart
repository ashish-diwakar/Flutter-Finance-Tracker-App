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

  DateTime createdAt = DateTime.now().toUtc();

  DateTime updatedAt = DateTime.now().toUtc();

  // ==========================================
  // STATUS
  // ==========================================

  bool isCompleted = false;

  // ==========================================
  // SYNC
  // ==========================================

  bool isDeleted = false;

  bool isSynced = false;

  // isSynced is device/sync state and is intentionally not portable.
  Map<String, dynamic> toBackupJson() {
    return {
      'id': uuid,
      'name': name,
      'description': description,
      'targetAmount': targetAmount,
      'currentAmount': currentAmount,
      'linkedAccountId': linkedAccountId,
      'targetDate': targetDate?.toUtc().toIso8601String(),
      'createdAt': createdAt.toUtc().toIso8601String(),
      'updatedAt': updatedAt.toUtc().toIso8601String(),
      'isCompleted': isCompleted,
      'isDeleted': isDeleted,
    };
  }

  Map<String, dynamic> toJson() {
    return {
      'id': uuid,

      'name': name,

      'description': description,

      'targetAmount': targetAmount,

      'currentAmount': currentAmount,

      'linkedAccountId': linkedAccountId,

      'targetDate': targetDate?.toUtc().toIso8601String(),

      'isCompleted': isCompleted,

      'createdAt': createdAt.toUtc().toIso8601String(),

      'updatedAt': updatedAt.toUtc().toIso8601String(),

      'isDeleted': isDeleted,
    };
  }
}
