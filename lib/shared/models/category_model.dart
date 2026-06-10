import 'package:isar_community/isar.dart';

part 'category_model.g.dart';

@collection
class CategoryModel {

  Id id  = Isar.autoIncrement;

  @Index(unique: true)
  late String uuid;

  late String name;

  late String type;

  String? icon;

  int? colorValue;

  bool isDefault = false;

  DateTime createdAt = DateTime.now();

  DateTime? updatedAt = DateTime.now();

  bool isSynced = false;

  bool isDeleted = false;

  int? monthlyBudget;

  Map<String, dynamic> toJson() {
    return {
      'id': uuid,
      'name': name,
      'type': type,
      'isDefault': isDefault,
      'updatedAt': updatedAt?.toIso8601String(),
      'isSynced': isSynced,
      'isDeleted': isDeleted,
      'monthlyBudget': monthlyBudget
    };
  }
}