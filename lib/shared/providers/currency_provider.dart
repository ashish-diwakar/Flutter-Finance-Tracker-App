import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/config/currency_config.dart';
import '../../core/constants/supported_currencies.dart';
import '../../core/services/app_settings_service.dart';

class CurrencyNotifier
    extends StateNotifier<
        CurrencyConfig> {

  CurrencyNotifier()
      : super(
          supportedCurrencies.first,
        ) {

    loadCurrency();
  }

  // ===========================================
  // LOAD SAVED CURRENCY
  // ===========================================

  Future<void>
      loadCurrency()
  async {

    final savedCode =

        await AppSettingsService
            .loadCurrencyCode();

    if (savedCode == null) {
      return;
    }

    try {

      final currency =

          supportedCurrencies
              .firstWhere(

        (c) =>
            c.code ==
            savedCode,
      );

      state = currency;

    } catch (_) {

      state =
          supportedCurrencies.first;
    }
  }

  // ===========================================
  // UPDATE CURRENCY
  // ===========================================

  Future<void>
      updateCurrency(
    CurrencyConfig currency,
  )
  async {

    state = currency;

    await AppSettingsService
        .saveCurrencyCode(
      currency.code,
    );
  }
}

final currencyProvider =
    StateNotifierProvider<
        CurrencyNotifier,
        CurrencyConfig>(

  (ref) {

    return CurrencyNotifier();
  },
);