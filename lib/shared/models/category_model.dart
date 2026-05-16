import 'package:isar/isar.dart';

part 'category_model.g.dart';

@collection
class CategoryModel {
  Id id = Isar.autoIncrement;

  late String name;

  late String type;

  String? icon;

  int? colorValue;

  bool isDefault = false;

  DateTime createdAt = DateTime.now();
}