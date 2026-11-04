# Finance Tracker DateTime audit — 2026-10-23

The audit reviewed all non-generated Dart in `lib/`, including date fields, local calendar reads, Isar filters, sorting/grouping, audit timestamps, recurrence, notification initialization, serialization, backup restoration, and exports.

The baseline inventory contains **294 executable date/time API calls across 52 files: 51 corrected and 243 intentionally preserved**. Nested calls count separately. Corrected includes calls receiving corrected calendar inputs. Field-only and query-only corrections are listed below, outside those counts. Declarations, comments and generated code are excluded. The complete A/B/C/D classification and baseline line references are in [datetime_audit_inventory.md](datetime_audit_inventory.md).

## Storage and compatibility

The installed Isar Community 3.3.2 implementation was inspected: `src/native/isar_writer_impl.dart` writes UTC epoch microseconds; `src/native/isar_reader_impl.dart` reconstructs those microseconds and calls `toLocal()`. Date query operands are encoded as epoch microseconds in the native query implementation. This matches the documented [Isar DateTime behavior](https://isar.dev/schema.html#datetime). Real database tests additionally verify local-midnight inclusion, an exclusive next-month boundary, microsecond precision and exact timestamp round trips.

Local month boundaries therefore work directly in Isar queries. UTC conversion is appropriate for audit instants and serialization; it is inappropriate before extracting the current local year/month for a financial report.

No Isar schemas, generated models, dependencies, currency representation or stored historical records were changed. No migration runs. Existing audit timestamps, balance calculations, repayment linking, transaction-type filtering and zero-savings behavior remain intact. Optional clocks were added to the dashboard and recurring services without breaking existing constructor calls. Group-title callers remain compatible with the optional deterministic `now` argument.

New JSON exports write date values as UTC ISO strings with `Z`. Existing `DateTime.parse` restoration accepts both these strings and previous offset-free local strings. Account/category `createdAt` fields are now exported and restored when present; older backups retain the existing fallback of a new timestamp when the field is absent. Existing backup keys and IDs retain their established meaning.

## Bugs and causes

1. Dashboard insights chose a UTC month and constructed local boundaries from its fields. Near midnight at a month boundary, that selects the wrong month. It now selects the device-local month and retains `[monthStart, nextMonthStart)` and deleted-row exclusion.
2. Transaction and recurring editors could pass UTC field values into date pickers, which use calendar components. Editor values and picker limits now use local representations of the same instants. Untouched transaction dates retain their instant when saved.
3. Transaction grouping read calendar components before localizing and stepped backwards by 24-hour durations. Local calendar normalization and calendar-day stepping now handle midnight and DST. Trend/chart keys and recurring/investment date displays also explicitly use local fields.
4. Recurrence used 24-hour durations for days/weeks, allowed overflowing day 31 into the following month, and dropped the time for months/years. Calendar stepping preserves the wall clock; short months clamp to their last day, then restore the start-date day in later months. Leap-day schedules similarly return to February 29 in leap years.
5. The recurring query excluded equality with the current instant, although the processing loop included it. Equality is now included. End dates now include the whole local calendar day. Nonpositive intervals and unknown frequencies are logged and skipped to avoid non-advancing loops.
6. Due-soon limits, the preceding-day repayment reminder, default due dates and custom export boundaries used fixed durations for calendar-day operations. Calendar constructors now perform those steps, preserving the intended 9am reminder time across DST.
7. Notification scheduling reconstructed the device-local fields in the configured timezone. If timezone initialization fell back to UTC, that moved the instant. `TZDateTime.from` now converts the requested instant directly. Device zone discovery and the Asia/Calcutta-to-Asia/Kolkata alias mapping remain intact.
8. Offset-free JSON from Isar-returned local dates could restore to a different instant in another timezone. UTC ISO serialization now preserves instants and precision; account/category creation timestamps were also previously omitted.
9. PDF generation and date formatting could print UTC calendar dates. Human-readable PDF dates now use local values. CSV output keeps its existing ISO representation for report interoperability; it is not the backup format.
10. Investment terms used elapsed `.inDays`, which truncated partial days and DST transitions. They now count local calendar days; the principal, rate, annualization formula and rounding are unchanged. This can correct a maturity estimate by the previously omitted calendar day.
11. Dashboard upcoming checks truncated durations to whole days, admitting schedules almost eight days away. They now compare exact instants against an inclusive seven-day upper bound, while excluding past/current instants as before.
12. Report initialization and navigation read the clock separately for year and month. A year rollover between calls could combine mismatched fields. Both now derive the month from one reading.

## Every changed production file

Paths are relative to the project root. Dart format was run on every file changed by this audit; several existing files had extensive formatting differences.

| File | Change |
| --- | --- |
| `lib/core/utils/calendar_date.dart` | New shared calendar boundaries, day arithmetic, date-only day counts and clamped recurrence. Native DateTimes use the device zone; explicitly zoned DateTimes retain their supplied zone. |
| `lib/core/services/notification_service.dart` | Convert scheduled instants directly into the configured notification zone. |
| `lib/shared/utils/transaction_date_helper.dart` | Local grouping, DST-safe day stepping and optional test clock. |
| `lib/shared/utils/provider_refresh_helper.dart` | Refresh reports for the local current month. |
| `lib/features/dashboard/data/services/dashboard_insights_service.dart` | Local month, deterministic clock and exact upcoming cutoff. |
| `lib/features/transactions/presentation/screens/add_transaction_screen.dart` | Local editor/picker values and limits; calendar default due date. |
| `lib/features/recurring/data/services/recurring_scheduler_service.dart` | Inclusive current instant, local inclusive end day, clamped calendar schedules, clock injection and invalid-schedule guard. |
| `lib/features/recurring/presentation/screens/add_recurring_transaction_screen.dart` | Local start/end editor values and initial date. |
| `lib/features/recurring/presentation/screens/recurring_transactions_screen.dart` | Local next-run calendar display. |
| `lib/features/borrow_lend/data/services/borrow_lend_notification_service.dart` | Preceding calendar day at 9am. |
| `lib/features/borrow_lend/presentation/providers/borrow_lend_provider.dart` | Three-calendar-day due-soon limit. |
| `lib/features/reports/data/services/monthly_trend_service.dart` | Group by local transaction year/month. |
| `lib/features/reports/presentation/providers/monthly_chart_provider.dart` | Group by local transaction year/month. |
| `lib/features/reports/presentation/screens/reports_screen.dart` | Initialize month from one clock reading. |
| `lib/features/navigation/presentation/screens/main_navigation_screen.dart` | Refresh month from one clock reading. |
| `lib/features/export/presentation/screens/export_screen.dart` | Calendar-safe custom export end boundary and inclusive date label. |
| `lib/features/export/data/services/pdf_export_service.dart` | Local generated date and local transaction/due-date formatting. |
| `lib/features/investments/core/investment_calculator.dart` | Count investment term in calendar days. |
| `lib/features/investments/presentation/screens/edit_investment_screen.dart` | Local maturity-date editor state. |
| `lib/features/investments/presentation/screens/portfolio_screen.dart` | Local maturity-date display. |
| `lib/shared/models/transaction_model.dart` | Exact-instant UTC JSON for transaction/due/audit dates. |
| `lib/shared/models/account_model.dart` | UTC JSON, including previously omitted creation timestamp. |
| `lib/shared/models/category_model.dart` | UTC JSON, including previously omitted creation timestamp. |
| `lib/shared/models/financial_goal_model.dart` | UTC JSON for target/audit dates. |
| `lib/features/backup/data/repositories/backup_repository.dart` | Restore optional account/category creation timestamps. |

Existing changes found on arrival in summary cards, dashboard UI, goals UI, transaction UI, notifications and `pubspec.yaml` were preserved. These are not claimed as work done by the audit. No GitHub service, commit or push operation was used.

## Tests and validation

Three test files were added:

- `test/calendar_date_test.dart`: deterministic Asia/Kolkata and America/New_York calendar tests covering midnight grouping, October/November, December/January, leap/non-leap February, exact month starts and one microsecond before the next boundary, UTC near midnight, month-end recurrence, leap-year recurrence, daily/weekly DST stepping, invalid schedules, calendar-based investment terms, UTC serialization precision and legacy local parsing.
- `test/datetime_isar_test.dart`: real temporary Isar database tests for boundaries, soft deletion, financial type filters, zero-savings behavior, saving/editing/reopening dates, exact audit timestamps, upcoming cutoff, recurring equality with now, month-end catch-up, inclusive end dates and idempotence. Uses the installed native library and never opens the user's database.
- `test/notification_datetime_test.dart`: mocked Android platform-channel tests for configured-zone conversion, past-event rejection, due-day/preceding-day reminder payloads, settled-reminder cancellation and availability of both Indian timezone aliases.

Validation: `dart format` completed on all changed Dart files. `flutter analyze --no-pub` reported **No issues found** (73.8 seconds). `flutter test --no-pub --reporter expanded` completed with **28 tests passed**. Earlier test-setup failures (native-library URI, environment initialization and assumptions about notification payload precision) were corrected before this final full-suite run.

`git diff --check` found trailing whitespace in the pre-existing edit at `lib/features/transactions/presentation/widgets/transaction_tile.dart:43`; that unrelated file content was preserved. It also emitted line-ending warnings for existing Windows working-tree files. Neither is an analyzer or test failure.

## Remaining manual verification and format limits

- Verify transaction and recurring pickers on Android devices around local midnight in positive and negative offsets, and notification delivery on a DST-observing device. Tests cover calendar math and platform arguments, not actual OS delivery or battery restrictions. Notifications retain the existing inexact scheduling mode.
- The installed notification plugin serializes second-precision wall-clock strings and a timezone name. It cannot distinguish both occurrences of a repeated DST hour through an explicit offset. Existing 9am repayment reminders avoid that ambiguous hour. Nonexistent recurring wall-clock times use the timezone constructor's normalization; arbitrary schedules in the DST transition hour merit device verification.
- Isar stores instants without the original timezone or a separate date-only value. A device timezone change can therefore change a displayed calendar date; guaranteeing fixed historical dates across travel would require an explicit data-model decision and migration. No historical meaning was guessed or rewritten.
- Older offset-free backups do not contain their original timezone, so that information cannot be recovered. Their established device-local parsing is preserved. New backups preserve exact instants across zones.
- Existing backup scope covers transactions, accounts and categories. This audit does not expand it to recurring schedules, investments or goals; their in-memory/database date handling was reviewed independently.
- Goal target dates currently have no active due-date notification/reporting UI to correct. Their model serialization is now unambiguous; creation/update timestamps remain UTC. Investment purchase/audit timestamps and account/category/default seed timestamps preserve their instant semantics.
