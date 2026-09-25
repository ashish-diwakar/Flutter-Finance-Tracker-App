import 'package:isar_community/isar.dart';

part 'transaction_model.g.dart';

@collection
class TransactionModel {
  Id id = Isar.autoIncrement;

  @Index(unique: true)
  late String uuid;

  late int amount;

  late String type;

  late DateTime transactionDate;

  String? notes;

  // Required for income/expense,
  // optional for borrowed/lent/repayment transactions.
  String? categoryId;

  late String accountId;

  String? toAccountId;

  // Used for borrowed/lent transactions.
  String? counterpartyName;

  // Links a repayment to the original borrowed/lent transaction UUID.
  String? relatedTransactionId;

  // Optional repayment/due date for borrowed/lent transactions.
  DateTime? dueDate;

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
      'toAccountId': toAccountId,
      'counterpartyName': counterpartyName,
      'relatedTransactionId': relatedTransactionId,
      'dueDate': dueDate?.toIso8601String(),
      'notes': notes,
      'transactionDate': transactionDate.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'isSynced': isSynced,
      'isDeleted': isDeleted,
    };
  }
}