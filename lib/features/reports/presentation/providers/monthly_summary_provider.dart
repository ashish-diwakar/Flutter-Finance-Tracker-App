import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/models/monthly_summary_model.dart';
import 'reports_repository_provider.dart';

final monthlySummaryProvider =
    FutureProvider.family<
        MonthlySummaryModel,
        DateTime>((ref, month) async {

  final repository =
      await ref.watch(
        reportsRepositoryProvider.future,
      );

  return repository.getMonthlySummary(
    month,
  );
});