import 'package:intl/intl.dart';

class TransactionDateHelper {

  static String getGroupTitle(
    DateTime date,
  ) {

    final now = DateTime.now();

    final today = DateTime(
      now.year,
      now.month,
      now.day,
    );

    final yesterday = today.subtract(
      const Duration(days: 1),
    );

    final transactionDay = DateTime(
      date.year,
      date.month,
      date.day,
    );

    if (transactionDay == today) {
      return 'Today';
    }

    if (transactionDay == yesterday) {
      return 'Yesterday';
    }

    if (transactionDay.isAfter(
      today.subtract(
        const Duration(days: 7),
      ),
    )) {
      return 'This Week';
    }

    if (transactionDay.month == now.month &&
        transactionDay.year == now.year) {
      return 'This Month';
    }

    return DateFormat(
      'MMMM yyyy',
    ).format(date);
  }
}