class ExpenseForecastModel {

  final double currentExpense;

  final double projectedExpense;

  final double dailyAverage;

  final int daysPassed;

  final int totalDays;

  ExpenseForecastModel({

    required this.currentExpense,

    required this.projectedExpense,

    required this.dailyAverage,

    required this.daysPassed,

    required this.totalDays,
  });
}