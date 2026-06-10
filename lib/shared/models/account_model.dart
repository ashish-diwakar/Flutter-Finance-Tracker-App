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

  DateTime createdAt = DateTime.now();

  DateTime? updatedAt = DateTime.now();

  bool isSynced = false;

  bool isDeleted = false;

  Map<String, dynamic> toJson() {
    return {
      'id': uuid,
      'name': name,
      'type': type,
      'currentBalance':
          currentBalance,
      'isDefault': isDefault,
      'updatedAt': updatedAt?.toIso8601String(),
      'isSynced': isSynced,
      'isDeleted': isDeleted,
    };
  }
}