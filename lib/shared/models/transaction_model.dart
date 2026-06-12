import 'package:isar_community/isar.dart';

part 'transaction_model.g.dart';

@collection
class TransactionModel {
  
  Id id  = Isar.autoIncrement;

  @Index(unique: true)
  late String uuid;

  late int amount;

  late String type;

  late DateTime transactionDate;

  String? notes;

  late String categoryId;

  late String accountId;

  DateTime createdAt = DateTime.now().toUtc();

  DateTime? updatedAt = DateTime.now().toUtc();

  bool isSynced = false;

  bool isDeleted = false;

  Map<String, dynamic> toJson() {
    return {
      'id': uuid,
      'amount': amount,
      'type': type,
      'categoryId': categoryId,
      'accountId': accountId,
      'notes': notes,
      'transactionDate':
          transactionDate.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'isSynced': isSynced,
      'isDeleted': isDeleted,
    };
  }
}