import 'package:finance_tracker/core/utils/calendar_date.dart';
import 'package:intl/intl.dart';

class TransactionDateHelper {
  static String getGroupTitle(DateTime date, {DateTime? now}) {
    final current = CalendarDate.local(now ?? DateTime.now());
    date = CalendarDate.local(date);

    final today = CalendarDate.startOfDay(current);

    final yesterday = CalendarDate.addDays(today, -1);

    final transactionDay = CalendarDate.startOfDay(date);

    if (transactionDay == today) {
      return 'Today';
    }

    if (transactionDay == yesterday) {
      return 'Yesterday';
    }

    if (transactionDay.isAfter(CalendarDate.addDays(today, -7))) {
      return 'This Week';
    }

    if (transactionDay.month == current.month &&
        transactionDay.year == current.year) {
      return 'This Month';
    }

    return DateFormat('MMMM yyyy').format(date);
  }
}
