import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/dashboard/presentation/providers/balance_provider.dart';
import '../../features/dashboard/presentation/providers/dashboard_insights_provider.dart';
import '../../features/dashboard/presentation/providers/expense_provider.dart';
import '../../features/dashboard/presentation/providers/income_provider.dart';
import '../../features/dashboard/presentation/providers/transactions_provider.dart';
import '../../features/recurring/presentation/providers/recurring_analytics_provider.dart';
import '../../features/recurring/presentation/providers/recurring_provider.dart';
import '../../features/reports/presentation/providers/budget_alerts_provider.dart';
import '../../features/investments/presentation/providers/investment_analytics_provider.dart';
import '../../features/reports/presentation/providers/budget_progress_provider.dart';
import '../../features/reports/presentation/providers/category_analytics_provider.dart';
import '../../features/reports/presentation/providers/expense_forecast_provider.dart';
import '../../features/reports/presentation/providers/financial_health_provider.dart';
import '../../features/reports/presentation/providers/financial_insights_provider.dart';
import '../../features/reports/presentation/providers/monthly_chart_provider.dart';
import '../../features/reports/presentation/providers/monthly_summary_provider.dart';
import '../../features/reports/presentation/providers/monthly_trends_provider.dart';

class ProviderRefreshHelper {

  // ==========================================
  // TRANSACTIONS
  // ==========================================

  static Future<void>
      refreshTransactionData(
    WidgetRef ref,
  ) async {

    ref.invalidate(
      transactionsStreamProvider,
    );

    ref.invalidate(
      totalIncomeProvider,
    );

    ref.invalidate(
      totalExpenseProvider,
    );

    ref.invalidate(
      totalBalanceProvider,
    );

    await Future.wait([

      ref.read(
        totalIncomeProvider.future,
      ),

      ref.read(
        totalExpenseProvider.future,
      ),
    ]);
  }

  
  // ==========================================
  // RECURRING TRANSACTIONS
  // ==========================================

  static Future<void>
      refreshRecurringTransactionData(
    WidgetRef ref,
  ) async {

    ref.invalidate(
      recurringTransactionsProvider,
    );

  }

  // ==========================================
  // BUDGETS
  // ==========================================

  static Future<void>
      refreshBudgetData(
    WidgetRef ref,
  ) async {

    ref.invalidate(
      budgetAlertsProvider,
    );

    await ref.read(
      budgetAlertsProvider.future,
    );
  }

  // ==========================================
  // DASHBOARD
  // ==========================================

  static Future<void>
      refreshDashboardData(
    WidgetRef ref,
  ) async {

    ref.invalidate(
      dashboardInsightsProvider,
    );

    await ref.read(
      dashboardInsightsProvider.future,
    );
  }

  // ==========================================
  // INVESTMENTS
  // ==========================================

  static Future<void>
      refreshInvestmentData(
    WidgetRef ref,
  ) async {

    ref.invalidate(
      investmentAnalyticsProvider,
    );

    await ref.read(
      investmentAnalyticsProvider.future,
    );
  }


  // ==========================================
  // Reports
  // ==========================================

  static Future<void>
      refreshReportsData(
    WidgetRef ref,
    DateTime month,
  ) async {

    ref.invalidate(
      monthlySummaryProvider(
        month,
      ),
    );

    ref.invalidate(
      categoryAnalyticsProvider(
        month,
      ),
    );

    ref.invalidate(
      monthlyChartProvider,
    );

    ref.invalidate(
      monthlyTrendsProvider,
    );

    ref.invalidate(
      budgetProgressProvider,
    );

    ref.invalidate(
      expenseForecastProvider,
    );

    ref.invalidate(
      financialInsightsProvider,
    );

    ref.invalidate(
      financialHealthProvider,
    );

    ref.invalidate(
      recurringAnalyticsProvider,
    );


    await Future.wait([

      ref.read(
        monthlySummaryProvider(
          month,
        ).future,
      ),

      ref.read(
        categoryAnalyticsProvider(
          month,
        ).future,
      ),

      ref.read(
        monthlyChartProvider.future,
      ),

      ref.read(
        budgetProgressProvider(month).future,
      ),
    ]);

  }

  // ==========================================
  // EVERYTHING FINANCIAL
  // ==========================================

  static Future<void>
      refreshAllFinancialData(
    WidgetRef ref,
  ) async {

    await Future.wait([

      refreshTransactionData(
        ref,
      ),

      refreshBudgetData(
        ref,
      ),

      refreshDashboardData(
        ref,
      ),

      refreshInvestmentData(
        ref,
      ),

      refreshRecurringTransactionData(
        ref,
      ),

      refreshReportsData(ref, DateTime.now()),
    ]);
  }
}