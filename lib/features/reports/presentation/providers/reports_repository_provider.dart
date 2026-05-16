import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/providers/database_provider.dart';
import '../../data/repositories/reports_repository.dart';

final reportsRepositoryProvider =
    FutureProvider<ReportsRepository>(
        (ref) async {

  final isar =
      await ref.watch(
        isarProvider.future,
      );

  return ReportsRepository(isar);
});