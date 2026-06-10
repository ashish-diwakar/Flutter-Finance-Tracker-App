import 'package:isar_community/isar.dart';

part 'recurring_transaction_model.g.dart';

@collection
class RecurringTransactionModel {
  
  Id id  = Isar.autoIncrement;


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
}