/// Version 2 envelope: format, schemaVersion, metadata, manifest, collections.
/// Each collection record uses `id` for its stable UUID. Local Isar IDs and
/// device-specific `isSynced` flags are excluded; `isDeleted` is preserved.
class BackupDataModel {
  static const format = 'finance-tracker-backup';
  static const schemaVersion = 2;

  final DateTime exportedAt;
  final String? appVersion;
  final String? currencyCode;
  final List<Map<String, dynamic>> accounts;
  final List<Map<String, dynamic>> categories;
  final List<Map<String, dynamic>> transactions;
  final List<Map<String, dynamic>> recurringTransactions;
  final List<Map<String, dynamic>> financialGoals;
  final List<Map<String, dynamic>> investments;

  BackupDataModel({
    required this.exportedAt,
    required this.appVersion,
    required this.currencyCode,
    required this.accounts,
    required this.categories,
    required this.transactions,
    required this.recurringTransactions,
    required this.financialGoals,
    required this.investments,
  });

  Map<String, dynamic> toJson() {
    return {
      'format': format,
      'schemaVersion': schemaVersion,
      'metadata': {
        'exportedAt': exportedAt.toUtc().toIso8601String(),
        'appVersion': appVersion,
        'currencyCode': currencyCode,
      },
      'manifest': {
        'accounts': {'recordCount': accounts.length},
        'categories': {'recordCount': categories.length},
        'transactions': {'recordCount': transactions.length},
        'recurringTransactions': {'recordCount': recurringTransactions.length},
        'financialGoals': {'recordCount': financialGoals.length},
        'investments': {'recordCount': investments.length},
      },
      'collections': {
        'accounts': accounts,
        'categories': categories,
        'transactions': transactions,
        'recurringTransactions': recurringTransactions,
        'financialGoals': financialGoals,
        'investments': investments,
      },
    };
  }
}

class LegacyBackupDataModel {
  final List<Map<String, dynamic>> transactions;
  final List<Map<String, dynamic>> categories;
  final List<Map<String, dynamic>> accounts;

  LegacyBackupDataModel({
    required this.transactions,
    required this.categories,
    required this.accounts,
  });

  factory LegacyBackupDataModel.fromJson(Map<String, dynamic> json) {
    return LegacyBackupDataModel(
      transactions: _legacyCollection(json, 'transactions'),
      categories: _legacyCollection(json, 'categories'),
      accounts: _legacyCollection(json, 'accounts'),
    );
  }

  static List<Map<String, dynamic>> _legacyCollection(
    Map<String, dynamic> json,
    String key,
  ) {
    final value = json[key] ?? [];
    if (value is! List) {
      throw FormatException('Legacy backup "$key" must be an array.');
    }

    return value.map((record) {
      if (record is! Map<String, dynamic>) {
        throw FormatException('Legacy backup "$key" records must be objects.');
      }

      return record;
    }).toList();
  }
}
