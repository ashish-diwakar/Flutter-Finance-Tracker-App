import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/providers/database_provider.dart';

import '../../data/services/recurring_analytics_service.dart';

final recurringAnalyticsProvider =
    FutureProvider(
  (ref) async {

    final isar =
        await ref.read(
      isarProvider.future,
    );

    final service =
        RecurringAnalyticsService(
      isar,
    );

    return service
        .calculateAnalytics();
  },
);