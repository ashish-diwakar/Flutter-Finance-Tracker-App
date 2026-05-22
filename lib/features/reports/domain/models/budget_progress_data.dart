class BudgetProgressData {

  final String category;

  final double spent;

  final double budget;

  BudgetProgressData({
    required this.category,
    required this.spent,
    required this.budget,
  });

  double get progress {

    if (budget == 0) {
      return 0;
    }

    return spent / budget;
  }
}