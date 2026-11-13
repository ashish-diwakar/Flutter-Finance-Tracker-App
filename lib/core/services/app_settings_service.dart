import 'package:shared_preferences/shared_preferences.dart';

import 'logger_service.dart';

class AppSettingsService {
  static const _currencyKey = 'selected_currency';
  static const _fullSnapshotRestoreKey = 'completed_full_snapshot_restore';
  static const _appLockEnabledKey = 'app_lock_enabled';

  /// Missing or unreadable preferences retain the mandatory lock.
  /// Reading never writes a default value.
  static Future<bool> loadAppLockEnabled() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final value = prefs.get(_appLockEnabledKey);
      if (value == null) return true;
      if (value is bool) return value;

      LoggerService.error(
        'Invalid app lock preference; defaulting to enabled.',
      );
    } catch (_) {
      LoggerService.error(
        'Unable to read app lock preference; defaulting to enabled.',
      );
    }
    return true;
  }

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
