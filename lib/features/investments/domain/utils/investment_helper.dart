class InvestmentHelper {

  static bool isFixedReturn(
    String type,
  ) {

    return [

      'FD',
      'RD',
      'PPF',
      'EPF',
      'NPS',
      'Bond',

    ].contains(type);
  }

  static bool supportsAutoMaturityCalculation(
    String type,
  ) {

    return [

      'FD',
      'RD',
      'Bond',

    ].contains(type);
  }

  static bool requiresInterestRate(
    String type,
  ) {

    return [

      'FD',
      'RD',
      'Bond',

    ].contains(type);
  }

  static bool isMarketLinked(
    String type,
  ) {

    return !isFixedReturn(type);
  }
}