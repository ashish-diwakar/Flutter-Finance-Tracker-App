import 'package:finance_tracker/shared/utils/default_data_uuid_fixer.dart';
import 'package:finance_tracker/core/services/app_settings_service.dart';
import 'package:isar_community/isar.dart';

import '../../shared/models/account_model.dart';
import '../../shared/models/category_model.dart';
import 'default_data.dart';
import 'full_snapshot_restore_marker.dart';

class DatabaseInitializer {
  static Future<void> seedDatabase(Isar isar) async {
    if (await AppSettingsService.hasLegacyFullSnapshotRestoreMarker()) {
      return;
    }

    await isar.writeTxn(() async {
      final marker = await isar.fullSnapshotRestoreMarkers.get(
        FullSnapshotRestoreMarker.singletonId,
      );
      if (marker != null) return;

      if (await isar.categoryModels.count() == 0) {
        await isar.categoryModels.putAll(
          fixUuidForCategoryList(DefaultData.categories),
        );
      }
      if (await isar.accountModels.count() == 0) {
        await isar.accountModels.putAll(
          fixUuidForAccountList(DefaultData.accounts),
        );
      }
    });
  }
}
