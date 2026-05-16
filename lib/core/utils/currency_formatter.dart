import 'package:intl/intl.dart';

class CurrencyFormatter {
  static String format(int amount) {

    final value = amount / 100;

    return NumberFormat.currency(
      locale: 'en_IN',
      symbol: '₹ ',
      decimalDigits: 2,
    ).format(value);
  }
}