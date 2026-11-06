import 'package:finance_tracker/core/config/currency_config.dart';
import 'package:finance_tracker/features/reports/data/services/budget_alert_checker.dart';
import 'package:finance_tracker/features/reports/domain/models/budget_alert_model.dart';
import 'package:finance_tracker/features/reports/presentation/widgets/budget_alerts_section.dart';
import 'package:finance_tracker/features/reports/presentation/providers/budget_alerts_provider.dart';
import 'package:finance_tracker/features/reports/presentation/screens/budget_alerts_screen.dart';
import 'package:finance_tracker/shared/providers/currency_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

const testCurrency = CurrencyConfig(
  code: 'INR',
  symbol: '₹',
  locale: 'en_IN',
  name: 'Indian Rupee',
  flag: '🇮🇳',
);

class _TestCurrencyNotifier extends CurrencyNotifier {
  _TestCurrencyNotifier() {
    state = testCurrency;
  }

  @override
  Future<void> loadCurrency() async {}
}

void main() {
  Widget buildSection(List<BudgetAlertModel> alerts) {
    return ProviderScope(
      overrides: [
        currencyProvider.overrideWith((ref) => _TestCurrencyNotifier()),
      ],
      child: MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: BudgetAlertsSection(alerts: alerts),
          ),
        ),
      ),
    );
  }

  testWidgets('exceeded budget retains percentage and caps visual bar', (
    tester,
  ) async {
    await tester.pumpWidget(
      buildSection([
        BudgetAlertModel(
          category: 'Long category name',
          spent: 125,
          budget: 100,
          percentage: 1.25,
          type: BudgetAlertType.exceeded,
        ),
      ]),
    );

    expect(find.text('Budget exceeded'), findsOneWidget);
    expect(find.text('125%'), findsOneWidget);
    expect(find.text('Spent'), findsOneWidget);
    expect(find.text('Budget'), findsOneWidget);
    expect(
      tester
          .widget<LinearProgressIndicator>(find.byType(LinearProgressIndicator))
          .value,
      1.0,
    );
  });

  testWidgets('zero budget displays unavailable utilization safely', (
    tester,
  ) async {
    await tester.pumpWidget(
      buildSection([
        BudgetAlertModel(
          category: 'No budget',
          spent: 0,
          budget: 0,
          percentage: double.nan,
          type: BudgetAlertType.safe,
        ),
      ]),
    );

    expect(find.text('—'), findsOneWidget);
    expect(
      tester
          .widget<LinearProgressIndicator>(find.byType(LinearProgressIndicator))
          .value,
      0.0,
    );
  });

  testWidgets('income target keeps income-specific labels and status', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          currencyProvider.overrideWith((ref) => _TestCurrencyNotifier()),
        ],
        child: MaterialApp(
          home: Scaffold(
            body: BudgetAlertsSection(
              alerts: [
                BudgetAlertModel(
                  category: 'Salary',
                  spent: 80,
                  budget: 100,
                  percentage: 0.8,
                  type: BudgetAlertType.warning,
                ),
              ],
              targetType: FinancialTargetType.incomeTarget,
            ),
          ),
        ),
      ),
    );

    expect(find.text('Approaching target'), findsOneWidget);
    expect(find.text('Received'), findsOneWidget);
    expect(find.text('Target'), findsOneWidget);
    expect(find.text('Budget Alerts'), findsNothing);
  });

  testWidgets('Budget Alerts gradient fills the complete body viewport', (
    tester,
  ) async {
    const params = (
      targetType: FinancialTargetType.expenseBudget,
      year: 2026,
      month: 11,
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          financialTargetAlertsProvider(
            params,
          ).overrideWith((ref) async => <BudgetAlertModel>[]),
        ],
        child: MaterialApp(home: BudgetAlertsScreen(month: DateTime(2026, 11))),
      ),
    );
    await tester.pumpAndSettle();

    final scaffold = tester.widget<Scaffold>(find.byType(Scaffold));
    final body = scaffold.body! as Stack;
    final bodyFinder = find.byWidget(body);
    final gradientFinder = find
        .descendant(of: bodyFinder, matching: find.byType(DecoratedBox))
        .first;

    expect(body.fit, StackFit.expand);
    expect(find.text('Budget Alerts'), findsOneWidget);
    expect(tester.getSize(gradientFinder), tester.getSize(bodyFinder));
  });
}
