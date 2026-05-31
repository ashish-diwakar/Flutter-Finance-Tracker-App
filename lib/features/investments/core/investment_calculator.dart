
import 'dart:math' as math;

class InvestmentCalculator {

  static int? calculateFdMaturityValue({

    required int principalAmount,
    required double interestRate,
    required DateTime purchaseDate,
    required DateTime maturityDate,
  }) {

    final years =
        maturityDate
            .difference(
              purchaseDate,
            )
            .inDays /
        365;

    final maturityValue =

        principalAmount *
            (1 +
                    (interestRate /
                        100))
                .toDouble()
                .pow(years);

    return maturityValue.round();
  }
}

extension _Pow on num {

  double pow(
    num exponent,
  ) {

    return math.pow(
      this,
      exponent,
    ).toDouble();
  }
}
