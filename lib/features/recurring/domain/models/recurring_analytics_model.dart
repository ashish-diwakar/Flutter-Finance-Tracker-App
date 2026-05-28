class RecurringAnalyticsModel {

  final double
      monthlyRecurringExpense;

  final double
      yearlyRecurringExpense;

  final double
      recurringIncomeRatio;

  final int activeRecurringCount;

  final String?
      topRecurringCategory;

  const RecurringAnalyticsModel({

    required this
        .monthlyRecurringExpense,

    required this
        .yearlyRecurringExpense,

    required this
        .recurringIncomeRatio,

    required this
        .activeRecurringCount,

    required this
        .topRecurringCategory,
  });
}