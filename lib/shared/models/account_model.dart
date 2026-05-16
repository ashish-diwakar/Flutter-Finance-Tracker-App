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
}