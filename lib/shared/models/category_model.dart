import 'package:isar_community/isar.dart';

part 'category_model.g.dart';

@collection
class CategoryModel {
  Id id = Isar.autoIncrement;

  @Index(unique: true)
  late String uuid;

  late String name;

  late String type;

  String? icon;

  int? colorValue;

  bool isDefault = false;

  DateTime createdAt = DateTime.now().toUtc();

  DateTime? updatedAt = DateTime.now().toUtc();

  bool isSynced = false;

  bool isDeleted = false;

  int? monthlyBudget;

  // isSynced is device/sync state and is intentionally not portable.
  Map<String, dynamic> toBackupJson() {
    return {
      'id': uuid,
      'name': name,
      'type': type,
      'icon': icon,
      'colorValue': colorValue,
      'isDefault': isDefault,
      'createdAt': createdAt.toUtc().toIso8601String(),
      'updatedAt': updatedAt?.toUtc().toIso8601String(),
      'isDeleted': isDeleted,
      'monthlyBudget': monthlyBudget,
    };
  }

  Map<String, dynamic> toJson() {
    return {
      'id': uuid,
      'name': name,
      'type': type,
      'isDefault': isDefault,
      'createdAt': createdAt.toUtc().toIso8601String(),
      'updatedAt': updatedAt?.toUtc().toIso8601String(),
      'isSynced': isSynced,
      'isDeleted': isDeleted,
      'monthlyBudget': monthlyBudget,
    };
  }
}
