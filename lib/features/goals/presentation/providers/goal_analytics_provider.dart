import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/providers/database_provider.dart';

import '../../data/services/goal_analytics_service.dart';

import '../../domain/models/goal_analytics_model.dart';

final goalAnalyticsProvider =
    FutureProvider<
        GoalAnalyticsModel>(
  (ref) async {

    final isar =
        await ref.watch(
      isarProvider.future,
    );

    final service =
        GoalAnalyticsService(
      isar,
    );

    return service
        .calculateAnalytics();
  },
);