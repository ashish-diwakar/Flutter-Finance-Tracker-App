import 'package:isar_community/isar.dart';

import '../../../../shared/enums/fixed_return_type.dart';
import '../../../../shared/models/investment_model.dart';

import '../../domain/models/investment_analytics_model.dart';

class InvestmentAnalyticsService {

  final Isar isar;

  InvestmentAnalyticsService(
    this.isar,
  );

  // Future<InvestmentAnalyticsModel>
  //     calculateAnalytics() async {

  //   final investments =
  //       await isar
  //           .investmentModels
  //           .filter()
  //           .isDeletedEqualTo(false)
  //           .findAll();

  //   double totalInvested = 0;

  //   double currentValue = 0;

  //   for (final investment
  //       in investments) {

  //     final investedAmount =
  //         (investment.quantity *
  //                 investment.purchasePrice) /
  //             100;

  //     final currentAmount =
  //         (investment.quantity *
  //                 investment.currentPrice) /
  //             100;

  //     totalInvested +=
  //         investedAmount;

  //     currentValue +=
  //         currentAmount;
  //   }

  //   final profitLoss =
  //       currentValue -
  //           totalInvested;

  //   final profitPercentage =
  //       totalInvested <= 0

  //           ? 0

  //           : (profitLoss /
  //                   totalInvested) *
  //               100;

  //   return InvestmentAnalyticsModel(

  //     totalInvested:
  //         totalInvested,

  //     currentValue:
  //         currentValue,

  //     profitLoss:
  //         profitLoss,

  //     profitPercentage:
  //         profitPercentage.toDouble(),
  //   );
  // }
  Future<InvestmentAnalyticsModel>
      calculateAnalytics()
  async {

    final investments =
        await isar
            .investmentModels
            .filter()
            .isDeletedEqualTo(false)
            .findAll();

    double totalInvested = 0;

    double currentValue = 0;

    for (final investment
        in investments) {

      // final isFixedReturn = [

      //   'FD',
      //   'RD',
      //   'PPF',
      //   'EPF',
      //   'NPS',
      //   'Bond',

      // ].contains(
      //   investment.type,
      // );
      final isFixedReturn =
      fixedReturnTypes.contains(
        investment.type.trim(),
      );

      if (isFixedReturn) {

        final investedAmount =
            investment.purchasePrice /
                100;

        final currentAmount =

            (investment.maturityValue ??
                    investment.purchasePrice) /
                100;

        totalInvested +=
            investedAmount;

        currentValue +=
            currentAmount;

      } else {

        final investedAmount =

            (investment.quantity *
                    investment.purchasePrice) /
                100;

        final currentAmount =

            (investment.quantity *
                    investment.currentPrice) /
                100;

        totalInvested +=
            investedAmount;

        currentValue +=
            currentAmount;
      }
    }

    final profitLoss =
        currentValue -
            totalInvested;

    final profitPercentage =
        totalInvested <= 0

            ? 0

            : (profitLoss /
                    totalInvested) *
                100;

    return InvestmentAnalyticsModel(

      totalInvested:
          totalInvested,

      currentValue:
          currentValue,

      profitLoss:
          profitLoss,

      profitPercentage:
          profitPercentage.toDouble(),
    );
  }
}