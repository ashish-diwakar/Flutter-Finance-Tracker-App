import 'package:isar/isar.dart';

part 'credit_card_model.g.dart';

@collection
class CreditCardModel {
  Id id = Isar.autoIncrement;

  late String cardName;

  late int cardLimit;

  late int usedAmount;

  late int availableLimit;

  late int billingDay;

  late int dueDay;

  double interestRate = 0;

  DateTime createdAt = DateTime.now();
}