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
}