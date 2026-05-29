import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../shared/providers/database_provider.dart';
import '../../data/services/investment_analytics_service.dart';
import '../../domain/models/investment_analytics_model.dart';

final investmentAnalyticsProvider =
    FutureProvider<
        InvestmentAnalyticsModel>(

  (ref) async {

    final isar =
        await ref.read(
      isarProvider.future,
    );

    final service =
        InvestmentAnalyticsService(
      isar,
    );

    return service
        .calculateAnalytics();
  },
);