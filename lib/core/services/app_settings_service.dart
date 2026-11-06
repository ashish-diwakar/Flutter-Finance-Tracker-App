import 'package:shared_preferences/shared_preferences.dart';

class AppSettingsService {

  static const _currencyKey =
      'selected_currency';
  static const _fullSnapshotRestoreKey =
      'completed_full_snapshot_restore';

  static Future<bool> hasCompletedFullSnapshotRestore() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_fullSnapshotRestoreKey) ?? false;
  }

  static Future<void> markFullSnapshotRestored() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = await prefs.setBool(_fullSnapshotRestoreKey, true);
    if (!saved) {
      throw StateError('Unable to persist full-snapshot restore state.');
    }
  }

  // ===========================================
  // SAVE CURRENCY
  // ===========================================

  static Future<void>
      saveCurrencyCode(
    String code,
  )
  async {

    final prefs =
        await SharedPreferences
            .getInstance();

    await prefs.setString(
      _currencyKey,
      code,
    );
  }

  // ===========================================
  // LOAD CURRENCY
  // ===========================================

  static Future<String?>
      loadCurrencyCode()
  async {

    final prefs =
        await SharedPreferences
            .getInstance();

    return prefs.getString(
      _currencyKey,
    );
  }
}