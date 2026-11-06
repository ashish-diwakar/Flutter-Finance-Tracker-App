import 'package:isar_community/isar.dart';

part 'investment_model.g.dart';

@collection
class InvestmentModel {
  Id id = Isar.autoIncrement;

  @Index(unique: true)
  late String uuid;

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

  DateTime createdAt = DateTime.now().toUtc();

  DateTime updatedAt = DateTime.now().toUtc();

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

  // isSynced is device/sync state and is intentionally not portable.
  Map<String, dynamic> toBackupJson() {
    return {
      'id': uuid,
      'name': name,
      'type': type,
      'symbol': symbol,
      'notes': notes,
      'quantity': quantity,
      'purchasePrice': purchasePrice,
      'currentPrice': currentPrice,
      'purchaseDate': purchaseDate.toUtc().toIso8601String(),
      'createdAt': createdAt.toUtc().toIso8601String(),
      'updatedAt': updatedAt.toUtc().toIso8601String(),
      'interestRate': interestRate,
      'maturityDate': maturityDate?.toUtc().toIso8601String(),
      'maturityValue': maturityValue,
      'investmentClass': investmentClass,
      'isDeleted': isDeleted,
    };
  }
}
