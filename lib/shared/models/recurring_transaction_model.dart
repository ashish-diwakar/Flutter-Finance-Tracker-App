import 'package:isar_community/isar.dart';

part 'recurring_transaction_model.g.dart';

@collection
class RecurringTransactionModel {
  Id id = Isar.autoIncrement;

  @Index(unique: true)
  late String uuid;

  late int amount;

  late String type;

  late String categoryId;

  late String accountId;

  String? notes;

  late DateTime startDate;

  DateTime? endDate;

  late String frequency;

  late int interval;

  late bool isActive;

  late DateTime nextRunDate;

  late DateTime updatedAt;

  bool isDeleted = false;

  bool isSynced = false;

  // isSynced is device/sync state and is intentionally not portable.
  Map<String, dynamic> toBackupJson() {
    return {
      'id': uuid,
      'amount': amount,
      'type': type,
      'categoryId': categoryId,
      'accountId': accountId,
      'notes': notes,
      'startDate': startDate.toUtc().toIso8601String(),
      'endDate': endDate?.toUtc().toIso8601String(),
      'frequency': frequency,
      'interval': interval,
      'isActive': isActive,
      'nextRunDate': nextRunDate.toUtc().toIso8601String(),
      'updatedAt': updatedAt.toUtc().toIso8601String(),
      'isDeleted': isDeleted,
    };
  }
}
