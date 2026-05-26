enum BudgetAlertType {

  safe,

  warning,

  exceeded,
}

class BudgetAlertModel {

  final String category;

  final double spent;

  final double budget;

  final double percentage;

  final BudgetAlertType type;

  BudgetAlertModel({

    required this.category,

    required this.spent,

    required this.budget,

    required this.percentage,

    required this.type,
  });
}