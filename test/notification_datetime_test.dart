import 'package:finance_tracker/core/services/notification_service.dart';
import 'package:finance_tracker/features/borrow_lend/data/services/borrow_lend_notification_service.dart';
import 'package:finance_tracker/shared/models/transaction_model.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:timezone/data/latest_all.dart' as data;
import 'package:timezone/timezone.dart' as tz;

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const channel = MethodChannel('dexterous.com/flutter/local_notifications');
  final calls = <MethodCall>[];

  setUp(() {
    dotenv.testLoad(fileInput: 'APP_NAME=Finance Tracker');
    data.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('America/New_York'));
    calls.clear();
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (call) async {
          calls.add(call);
          return null;
        });
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
  });

  test('scheduled instant converts into configured zone', () async {
    final instant = DateTime.utc(2090, 11, 5, 6, 30, 0, 123);
    await NotificationService.scheduleNotification(
      id: 1,
      title: 'Test',
      body: 'Test',
      scheduledAt: instant,
      payload: 'test',
    );
    final call = calls.singleWhere((call) => call.method == 'zonedSchedule');
    final expected = tz.TZDateTime.from(instant, tz.local);
    expect(call.arguments['timeZoneName'], 'America/New_York');
    // The installed plugin sends scheduled times with second precision.
    expect(call.arguments['scheduledDateTime'], contains('01:30:00'));
    expect(
      call.arguments['scheduledDateTime'],
      contains(expected.year.toString()),
    );
    expect(call.arguments['payload'], 'test');
  });

  test('past instants are not scheduled', () async {
    await NotificationService.scheduleNotification(
      id: 2,
      title: 'Test',
      body: 'Test',
      scheduledAt: DateTime.utc(2000),
    );
    expect(calls, isEmpty);
  });

  test(
    'due-date reminders use 9am on due day and preceding calendar day',
    () async {
      final due = DateTime(2090, 3, 12);
      // Also exercise timezone initialization's UTC fallback on a non-UTC device.
      tz.setLocalLocation(tz.getLocation('UTC'));
      final item = TransactionModel()
        ..uuid = 'loan'
        ..type = 'borrowed'
        ..dueDate = due.toUtc()
        ..counterpartyName = 'Person';
      await BorrowLendNotificationService.syncReminders(
        transaction: item,
        outstandingAmount: 10000,
        outstandingAmountText: '100',
      );
      final scheduled = calls
          .where((call) => call.method == 'zonedSchedule')
          .toList();
      expect(scheduled, hasLength(2));
      final expectedDue = tz.TZDateTime.from(
        DateTime(2090, 3, 12, 9),
        tz.local,
      );
      final expectedBefore = tz.TZDateTime.from(
        DateTime(2090, 3, 11, 9),
        tz.local,
      );
      // The plugin serializes the wall-clock date separately from the zone name.
      String wall(DateTime value) => DateTime.utc(
        value.year,
        value.month,
        value.day,
        value.hour,
        value.minute,
        value.second,
      ).toIso8601String().split('.').first;
      expect(scheduled[0].arguments['scheduledDateTime'], wall(expectedBefore));
      expect(scheduled[1].arguments['scheduledDateTime'], wall(expectedDue));
      expect(
        scheduled.every(
          (call) => call.arguments['payload'] == 'borrow_lend:loan',
        ),
        isTrue,
      );
      calls.clear();
      await BorrowLendNotificationService.syncReminders(
        transaction: item,
        outstandingAmount: 0,
        outstandingAmountText: '0',
      );
      expect(calls.where((call) => call.method == 'zonedSchedule'), isEmpty);
    },
  );

  test('historical Calcutta and Kolkata aliases remain available', () {
    final instant = DateTime.utc(2026, 10, 31, 18, 30);
    final historical = tz.TZDateTime.from(
      instant,
      tz.getLocation('Asia/Calcutta'),
    );
    final canonical = tz.TZDateTime.from(
      instant,
      tz.getLocation('Asia/Kolkata'),
    );
    expect(historical.timeZoneOffset, canonical.timeZoneOffset);
    expect((canonical.month, canonical.day), (11, 1));
  });
}
