import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/providers/database_provider.dart';
import '../../data/repositories/backup_repository.dart';

final backupRepositoryProvider =
    FutureProvider<BackupRepository>(
        (ref) async {

  final isar =
      await ref.watch(
        isarProvider.future,
      );

  return BackupRepository(isar);
});