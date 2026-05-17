import 'package:isar/isar.dart';

part 'account_model.g.dart';

@collection
class AccountModel {
  Id id = Isar.autoIncrement;

  late String name;

  late String type;

  late int currentBalance;

  bool isArchived = false;

  DateTime createdAt = DateTime.now();
  
  DateTime? updatedAt;

  bool isSynced = false;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'type': type,
      'currentBalance':
          currentBalance,
      'updatedAt': updatedAt?.toIso8601String(),
      'isSynced': isSynced,
    };
  }
}