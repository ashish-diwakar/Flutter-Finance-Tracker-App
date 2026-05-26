import 'package:isar/isar.dart';

part 'recurring_transaction_model.g.dart';

@collection
class RecurringTransactionModel {

  Id id = Isar.autoIncrement;

  late int amount;

  late String type;

  late int categoryId;

  late int accountId;

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
}