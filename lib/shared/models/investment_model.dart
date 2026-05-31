import 'package:isar/isar.dart';

part 'investment_model.g.dart';

@collection
class InvestmentModel {

  Id id = Isar.autoIncrement;

  // ===========================================
  // BASIC INFO
  // ===========================================

  late String name;

  late String type;

  String? symbol;

  String? notes;

  // ===========================================
  // INVESTMENT VALUES
  // ===========================================

  late int quantity;

  late int purchasePrice;

  late int currentPrice;

  // ===========================================
  // DATES
  // ===========================================

  late DateTime purchaseDate;

  DateTime createdAt =
      DateTime.now();

  DateTime updatedAt =
      DateTime.now();

  // ===========================================
  // FIXED RETURN INVESTMENTS
  // ===========================================

  double? interestRate;

  DateTime? maturityDate;

  int? maturityValue;

  // ===========================================
  // CLASSIFICATION
  // ===========================================

  String investmentClass = 'market';

  // ===========================================
  // SYNC
  // ===========================================

  bool isDeleted = false;

  bool isSynced = false;
}