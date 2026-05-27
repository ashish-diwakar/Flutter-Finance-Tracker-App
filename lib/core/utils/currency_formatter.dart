import 'package:intl/intl.dart';
import '../config/currency_config.dart';

// class CurrencyFormatter {
//   static String format(int amount) {

//     final value = amount / 100;

//     return NumberFormat.currency(
//       locale: 'en_IN',
//       symbol: '₹ ',
//       decimalDigits: 2,
//     ).format(value);
//   }
// }

class CurrencyFormatter {

  static String format({

    required int amount,

    required CurrencyConfig
        currency,
  }) {

    final value = amount / 100;
    final formatter =
        NumberFormat.currency(

      locale:
          currency.locale,

      symbol:
          currency.symbol,
    );

    return formatter.format(
      value,
    );
  }

  static String formatDouble({

    required double amount,

    required CurrencyConfig
        currency,
  }) {

    final formatter =
        NumberFormat.currency(

      locale:
          currency.locale,

      symbol:
          currency.symbol,
    );

    return formatter.format(
      amount,
    );
  }
}