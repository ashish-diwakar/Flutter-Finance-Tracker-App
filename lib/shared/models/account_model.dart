import 'package:isar_community/isar.dart';

part 'account_model.g.dart';

@collection
class AccountModel {
  Id id = Isar.autoIncrement;

  @Index(unique: true)
  late String uuid;

  late String name;

  late String type;

  late int currentBalance;

  bool isArchived = false;

  bool isDefault = false;

  DateTime createdAt = DateTime.now().toUtc();

  DateTime? updatedAt = DateTime.now().toUtc();

  bool isSynced = false;

  bool isDeleted = false;

  // isSynced is device/sync state and is intentionally not portable.
  Map<String, dynamic> toBackupJson() {
    return {
      'id': uuid,
      'name': name,
      'type': type,
      'currentBalance': currentBalance,
      'isArchived': isArchived,
      'isDefault': isDefault,
      'createdAt': createdAt.toUtc().toIso8601String(),
      'updatedAt': updatedAt?.toUtc().toIso8601String(),
      'isDeleted': isDeleted,
    };
  }

  Map<String, dynamic> toJson() {
    return {
      'id': uuid,
      'name': name,
      'type': type,
      'currentBalance': currentBalance,
      'isDefault': isDefault,
      'createdAt': createdAt.toUtc().toIso8601String(),
      'updatedAt': updatedAt?.toUtc().toIso8601String(),
      'isSynced': isSynced,
      'isDeleted': isDeleted,
    };
  }
}
