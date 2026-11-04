import 'package:finance_tracker/core/utils/calendar_date.dart';
import 'package:finance_tracker/shared/utils/transaction_date_helper.dart';
import 'package:finance_tracker/features/investments/core/investment_calculator.dart';
import 'package:finance_tracker/shared/models/transaction_model.dart';
import 'package:finance_tracker/shared/models/account_model.dart';
import 'package:finance_tracker/shared/models/category_model.dart';
import 'package:finance_tracker/shared/models/financial_goal_model.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:timezone/data/latest_all.dart' as data;
import 'package:timezone/timezone.dart' as tz;

void main() {
  setUpAll(data.initializeTimeZones);

  for (final zone in ['Asia/Kolkata', 'America/New_York']) {
    group(zone, () {
      late tz.Location location;
      setUp(() => location = tz.getLocation(zone));

      test('group labels cross midnight and DST by calendar day', () {
        final now = tz.TZDateTime(location, 2026, 11, 2, 0, 5);
        expect(TransactionDateHelper.getGroupTitle(now, now: now), 'Today');
        final yesterday = tz.TZDateTime(location, 2026, 11, 1, 23, 59);
        expect(
          TransactionDateHelper.getGroupTitle(yesterday, now: now),
          'Yesterday',
        );
      });

      for (final values in [(2026, 11), (2027, 1), (2024, 3), (2026, 3)]) {
        test('half-open month ending ${values.$1}-${values.$2}', () {
          final next = tz.TZDateTime(location, values.$1, values.$2);
          final start = CalendarDate.startOfMonth(
            tz.TZDateTime(location, values.$1, values.$2 - 1, 15),
          );
          final end = CalendarDate.nextMonth(start);
          final before = next.subtract(const Duration(microseconds: 1));
          expect(end.isAtSameMomentAs(next), isTrue);
          expect(start.isBefore(end), isTrue);
          expect(!start.isBefore(start) && start.isBefore(end), isTrue);
          expect(!before.isBefore(start) && before.isBefore(end), isTrue);
          expect(next.isBefore(end), isFalse);
          expect(CalendarDate.addDays(CalendarDate.at(before), 1), next);
        });
      }

      test('UTC near midnight resolves to local calendar month', () {
        final utc = zone == 'Asia/Kolkata'
            ? DateTime.utc(2026, 10, 31, 18, 30)
            : DateTime.utc(2026, 11, 1, 3, 59);
        final local = tz.TZDateTime.from(utc, location);
        expect(local.month, zone == 'Asia/Kolkata' ? 11 : 10);
        expect(CalendarDate.startOfMonth(local).month, local.month);
        expect(local.isAtSameMomentAs(utc), isTrue);
      });

      test('monthly recurrence clamps February and restores day 31', () {
        final anchor = tz.TZDateTime(location, 2024, 1, 31, 9, 15);
        final feb = CalendarDate.nextRecurring(
          current: anchor,
          anchor: anchor,
          frequency: 'monthly',
          interval: 1,
        );
        final march = CalendarDate.nextRecurring(
          current: feb,
          anchor: anchor,
          frequency: 'monthly',
          interval: 1,
        );
        expect((feb.month, feb.day, feb.hour, feb.minute), (2, 29, 9, 15));
        expect((march.month, march.day, march.hour), (3, 31, 9));
      });

      test('yearly leap day returns after short years', () {
        final anchor = tz.TZDateTime(location, 2024, 2, 29, 9);
        var date = anchor as DateTime;
        for (var i = 0; i < 4; i++) {
          date = CalendarDate.nextRecurring(
            current: date,
            anchor: anchor,
            frequency: 'yearly',
            interval: 1,
          );
        }
        expect((date.year, date.month, date.day, date.hour), (2028, 2, 29, 9));
      });

      test('daily and weekly schedules preserve wall clock across DST', () {
        for (final monthDay in [(3, 7), (10, 31)]) {
          final start = tz.TZDateTime(
            location,
            2026,
            monthDay.$1,
            monthDay.$2,
            9,
          );
          for (final frequency in ['daily', 'weekly']) {
            final next = CalendarDate.nextRecurring(
              current: start,
              anchor: start,
              frequency: frequency,
              interval: 1,
            );
            expect(next.hour, 9);
            expect(
              CalendarDate.daysBetween(start, next),
              frequency == 'daily' ? 1 : 7,
            );
          }
          final due = CalendarDate.addDays(start, 1);
          expect(CalendarDate.addDays(due, -1), start);
        }
      });
    });
  }

  test('invalid recurrence cannot create a non-advancing loop', () {
    final date = DateTime(2026, 1, 1);
    expect(
      () => CalendarDate.nextRecurring(
        current: date,
        anchor: date,
        frequency: 'monthly',
        interval: 0,
      ),
      throwsArgumentError,
    );
    expect(
      () => CalendarDate.nextRecurring(
        current: date,
        anchor: date,
        frequency: 'unknown',
        interval: 1,
      ),
      throwsArgumentError,
    );
  });

  test('date-based investment term ignores DST and time-of-day', () {
    expect(
      InvestmentCalculator.calculateFdMaturityValue(
        principalAmount: 100000,
        interestRate: 10,
        purchaseDate: DateTime(2025, 1, 1, 18),
        maturityDate: DateTime(2026, 1, 1),
      ),
      110000,
    );
  });

  test(
    'backup serializes calendar dates and audit timestamps as exact instants',
    () {
      final instant = DateTime.utc(2026, 10, 31, 18, 30, 0, 123, 456);
      final transaction = TransactionModel()
        ..uuid = 'transaction'
        ..amount = 100
        ..type = 'expense'
        ..accountId = 'account'
        ..transactionDate = instant.toLocal()
        ..dueDate = instant.toLocal()
        ..createdAt = instant.toLocal()
        ..updatedAt = instant.toLocal();
      final json = transaction.toJson();
      for (final key in [
        'transactionDate',
        'dueDate',
        'createdAt',
        'updatedAt',
      ]) {
        expect(json[key], endsWith('Z'));
        expect(DateTime.parse(json[key]).isAtSameMomentAs(instant), isTrue);
      }
      final account = AccountModel()
        ..uuid = 'a'
        ..name = 'A'
        ..type = 'cash'
        ..currentBalance = 0
        ..createdAt = instant.toLocal()
        ..updatedAt = instant.toLocal();
      final category = CategoryModel()
        ..uuid = 'c'
        ..name = 'C'
        ..type = 'expense'
        ..createdAt = instant.toLocal()
        ..updatedAt = instant.toLocal();
      final goal = FinancialGoalModel()
        ..uuid = 'g'
        ..name = 'G'
        ..targetAmount = 100
        ..currentAmount = 0
        ..targetDate = instant.toLocal()
        ..createdAt = instant.toLocal()
        ..updatedAt = instant.toLocal();
      for (final value in [
        account.toJson(),
        category.toJson(),
        goal.toJson(),
      ]) {
        expect(
          DateTime.parse(value['createdAt']).isAtSameMomentAs(instant),
          isTrue,
        );
        expect(
          DateTime.parse(value['updatedAt']).isAtSameMomentAs(instant),
          isTrue,
        );
      }
      // Legacy offset-free backups retain the established device-local parsing.
      expect(DateTime.parse('2026-11-01T00:00:00'), DateTime(2026, 11, 1));
      expect(
        DateTime.parse('2026-11-01T00:00:00+05:30'),
        instant.subtract(const Duration(milliseconds: 123, microseconds: 456)),
      );
    },
  );
}
