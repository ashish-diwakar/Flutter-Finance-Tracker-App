import '../../../../shared/enums/fixed_return_type.dart';

class InvestmentHelper {

  static bool isFixedReturn(
    String type,
  ) {

    return fixedReturnTypes.contains(type);

  }

  static bool supportsAutoMaturityCalculation(
    String type,
  ) {

    return fixedReturnTypesThatSupportsAutoMaturityCalculation.contains(type);
  }

  static bool requiresInterestRate(
    String type,
  ) {

    return fixedReturnTypesThatRequiresInterestRate.contains(type);
  }

  static bool isMarketLinked(
    String type,
  ) {

    return !isFixedReturn(type);
  }
}