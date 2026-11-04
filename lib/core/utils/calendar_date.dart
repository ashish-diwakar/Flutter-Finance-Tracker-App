import 'package:timezone/timezone.dart' as tz;

/// Calendar operations in the device zone (or an explicitly zoned DateTime).
/// Durations remain appropriate for elapsed time, but not calendar-day steps.
class CalendarDate {
  static DateTime local(DateTime date) =>
      date is tz.TZDateTime ? date : date.toLocal();

  static DateTime at(
    DateTime date, {
    int? year,
    int? month,
    int? day,
    int hour = 0,
    int minute = 0,
    int second = 0,
    int millisecond = 0,
    int microsecond = 0,
  }) {
    final value = local(date);
    if (value is tz.TZDateTime) {
      return tz.TZDateTime(
        value.location,
        year ?? value.year,
        month ?? value.month,
        day ?? value.day,
        hour,
        minute,
        second,
        millisecond,
        microsecond,
      );
    }
    return DateTime(
      year ?? value.year,
      month ?? value.month,
      day ?? value.day,
      hour,
      minute,
      second,
      millisecond,
      microsecond,
    );
  }

  static DateTime startOfDay(DateTime date) => at(date);

  static DateTime startOfMonth(DateTime date) => at(date, day: 1);

  static DateTime nextMonth(DateTime date) =>
      at(date, month: local(date).month + 1, day: 1);

  static DateTime addDays(DateTime date, int days) {
    final value = local(date);
    return at(
      value,
      day: value.day + days,
      hour: value.hour,
      minute: value.minute,
      second: value.second,
      millisecond: value.millisecond,
      microsecond: value.microsecond,
    );
  }

  static int daysBetween(DateTime start, DateTime end) {
    final a = local(start);
    final b = local(end);
    // UTC here measures calendar dates without DST or time-of-day truncation.
    return DateTime.utc(
      b.year,
      b.month,
      b.day,
    ).difference(DateTime.utc(a.year, a.month, a.day)).inDays;
  }

  static DateTime nextRecurring({
    required DateTime current,
    required DateTime anchor,
    required String frequency,
    required int interval,
  }) {
    if (interval <= 0) throw ArgumentError.value(interval, 'interval');
    final date = local(current);
    final start = local(anchor);
    if (frequency == 'daily' || frequency == 'weekly') {
      return addDays(date, interval * (frequency == 'weekly' ? 7 : 1));
    }
    if (frequency != 'monthly' && frequency != 'yearly') {
      throw ArgumentError.value(frequency, 'frequency');
    }
    final target = at(
      date,
      year: date.year + (frequency == 'yearly' ? interval : 0),
      month: date.month + (frequency == 'monthly' ? interval : 0),
      day: 1,
    );
    final lastDay = at(target, month: target.month + 1, day: 0).day;
    // Clamp short months, then restore the original day in later months.
    return at(
      target,
      day: start.day > lastDay ? lastDay : start.day,
      hour: date.hour,
      minute: date.minute,
      second: date.second,
      millisecond: date.millisecond,
      microsecond: date.microsecond,
    );
  }
}
