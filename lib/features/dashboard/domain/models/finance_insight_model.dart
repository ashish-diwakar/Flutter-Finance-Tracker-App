enum FinanceInsightType {

  info,

  success,

  warning,

  danger,
}

class FinanceInsightModel {

  final String title;

  final String description;

  final FinanceInsightType type;

  FinanceInsightModel({

    required this.title,

    required this.description,

    required this.type,
  });
}