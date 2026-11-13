import 'package:shared_preferences/shared_preferences.dart';

import 'logger_service.dart';

class AppLockPreferenceWriteResult {
  const AppLockPreferenceWriteResult({
    required this.confirmed,
    required this.observedEnabled,
  });

  final bool confirmed;
  final bool? observedEnabled;
}

class AppSettingsService {
  static const _currencyKey = 'selected_currency';
  static const _fullSnapshotRestoreKey = 'completed_full_snapshot_restore';
  static const _appLockEnabledKey = 'app_lock_enabled';

  /// Missing or unreadable preferences retain the mandatory lock.
  /// Reading never writes a default value.
  static Future<bool> loadAppLockEnabled() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return _resolvedAppLockValue(prefs.get(_appLockEnabledKey));
    } catch (_) {
      LoggerService.error(
        'Unable to read app lock preference; defaulting to enabled.',
      );
      return true;
    }
  }

  static bool _resolvedAppLockValue(Object? value) {
    if (value == null) return true;
    if (value is bool) return value;
    LoggerService.error('Invalid app lock preference; defaulting to enabled.');
    return true;
  }

  /// Writes only a user-approved transition, then reloads platform storage.
  /// A null observation means the stored state could not be verified.
  static Future<AppLockPreferenceWriteResult> saveAppLockEnabled(
    bool enabled,
  ) async {
    late SharedPreferences prefs;
    try {
      prefs = await SharedPreferences.getInstance();
    } catch (_) {
      LoggerService.error('Unable to access app lock preference storage.');
      return const AppLockPreferenceWriteResult(
        confirmed: false,
        observedEnabled: null,
      );
    }

    var accepted = false;
    try {
      accepted = await prefs.setBool(_appLockEnabledKey, enabled);
    } catch (_) {
      LoggerService.error('Unable to save app lock preference.');
    }

    try {
      await prefs.reload();
      final stored = prefs.get(_appLockEnabledKey);
      return AppLockPreferenceWriteResult(
        confirmed: accepted && stored == enabled,
        observedEnabled: _resolvedAppLockValue(stored),
      );
    } catch (_) {
      LoggerService.error('Unable to verify app lock preference after saving.');
      return const AppLockPreferenceWriteResult(
        confirmed: false,
        observedEnabled: null,
      );
    }
  }

  /// Rechecks platform storage after an unverified write.
  static Future<bool?> reloadAppLockEnabled() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.reload();
      return _resolvedAppLockValue(prefs.get(_appLockEnabledKey));
    } catch (_) {
      LoggerService.error('Unable to verify app lock preference.');
      return null;
    }
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
