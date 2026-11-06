import 'package:shared_preferences/shared_preferences.dart';

class AppSettingsService {
  static const _currencyKey = 'selected_currency';
  static const _fullSnapshotRestoreKey = 'completed_full_snapshot_restore';

  static Future<bool> hasLegacyFullSnapshotRestoreMarker() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_fullSnapshotRestoreKey) ?? false;
  }

  // ===========================================
  // SAVE CURRENCY
  // ===========================================

  static Future<void> saveCurrencyCode(String code) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString(_currencyKey, code);
  }

  // ===========================================
  // LOAD CURRENCY
  // ===========================================

  static Future<String?> loadCurrencyCode() async {
    final prefs = await SharedPreferences.getInstance();

    return prefs.getString(_currencyKey);
  }
}
