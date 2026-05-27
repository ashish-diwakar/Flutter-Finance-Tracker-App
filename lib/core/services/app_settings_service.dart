import 'package:shared_preferences/shared_preferences.dart';

class AppSettingsService {

  static const _currencyKey =
      'selected_currency';

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