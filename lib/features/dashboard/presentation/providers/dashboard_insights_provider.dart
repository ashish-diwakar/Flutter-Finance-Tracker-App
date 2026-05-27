import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/providers/database_provider.dart';

import '../../data/services/dashboard_insights_service.dart';

final dashboardInsightsProvider =
    FutureProvider(
  (ref) async {

    final isar =
        await ref.read(
      isarProvider.future,
    );

    final service =
        DashboardInsightsService(
      isar,
    );

    return service
        .generateInsights();
  },
);