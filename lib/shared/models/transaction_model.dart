import 'package:isar/isar.dart';

part 'transaction_model.g.dart';

@collection
class TransactionModel {
  Id id = Isar.autoIncrement;

  late int amount;

  late String type;

  late DateTime transactionDate;

  String? notes;

  late int categoryId;

  late int accountId;

  DateTime createdAt = DateTime.now();

  DateTime updatedAt = DateTime.now();

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'amount': amount,
      'type': type,
      'categoryId': categoryId,
      'accountId': accountId,
      'notes': notes,
      'transactionDate':
          transactionDate.toIso8601String(),
    };
  }
}