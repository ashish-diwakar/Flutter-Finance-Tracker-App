class BackupDataModel {

  final List<dynamic> transactions;
  final List<dynamic> categories;
  final List<dynamic> accounts;

  BackupDataModel({
    required this.transactions,
    required this.categories,
    required this.accounts,
  });

  Map<String, dynamic> toJson() {

    return {
      'transactions': transactions,
      'categories': categories,
      'accounts': accounts,
    };
  }

  factory BackupDataModel.fromJson(
    Map<String, dynamic> json,
  ) {

    return BackupDataModel(
      transactions:
          json['transactions'] ?? [],
      categories:
          json['categories'] ?? [],
      accounts:
          json['accounts'] ?? [],
    );
  }
}