import 'package:isar/isar.dart';

part 'loan_model.g.dart';

@collection
class LoanModel {
  Id id = Isar.autoIncrement;

  late String loanName;

  late int principalAmount;

  late double interestRate;

  late int emiAmount;

  late int remainingAmount;

  late DateTime startDate;

  DateTime? endDate;

  DateTime createdAt = DateTime.now();
}