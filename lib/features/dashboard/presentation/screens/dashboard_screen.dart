import 'package:finance_tracker/core/constants/app_constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/widgets/aurora_app_bar.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/widgets/summary_card.dart';
import '../../../../core/services/logger_service.dart';
import '../../../../shared/utils/provider_refresh_helper.dart';
import '../../../goals/presentation/widgets/goals_summary_card.dart';
import '../../../transactions/presentation/screens/add_transaction_screen.dart';
import '../../../transactions/presentation/screens/transaction_list_screen.dart';
import '../providers/balance_provider.dart';
import '../providers/expense_provider.dart';
import '../providers/income_provider.dart';
import '../providers/dashboard_insights_provider.dart';
import '../widgets/dashboard_insights_section.dart';
import '../../../../shared/providers/currency_provider.dart';

class DashboardScreen
    extends ConsumerStatefulWidget {

  const DashboardScreen({
    super.key,
  });

  @override
  ConsumerState<DashboardScreen>
      createState() =>
          _DashboardScreenState();
}

class _DashboardScreenState
    extends ConsumerState<DashboardScreen> {

  bool syncing = false;

  Future<void> syncData()
  async {

    if (syncing) {
      return;
    }

    setState(() {
      syncing = true;
    });

    try {

      await refreshDashboard();

      if (!mounted) {
        return;
      }

    } catch (e, stackTrace) {

        LoggerService.error(
          'Sync Error: $e',
        );
        LoggerService.error(
          'Stack Trace: $stackTrace',
        );
        
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(

        const SnackBar(

          content: Text(
            'Unable to sync. Please try again.',
          ),
        ),
      );

    } finally {

      if (mounted) {

        setState(() {
          syncing = false;
        });
      }
    }
  }

  Future<void> refreshDashboard()
  async {
    await ProviderRefreshHelper
        .refreshDashboardData(
      ref,
    );
  }

  @override
  Widget build(
    BuildContext context,
  ) {

    final income =
        ref.watch(
              totalIncomeProvider,
            ).value ??
            0;

    final expense =
        ref.watch(
              totalExpenseProvider,
            ).value ??
            0;

    final balance =
        ref.watch(
              totalBalanceProvider,
            );

    final appName = AppConstants.appName;

    final insightsAsync =
        ref.watch(
      dashboardInsightsProvider,
    );


    final currency =
        ref.watch(
      currencyProvider,
    );

    return Scaffold(

      appBar: AuroraAppBar(
        title: Text(appName),
        actions: [
          IconButton.filledTonal(
            tooltip: 'Add Transaction',
            style: IconButton.styleFrom(
              backgroundColor: const Color(0xFFD0F1DC),
              foregroundColor: const Color(0xFF105C45),
            ),
            icon: const Icon(Icons.add),
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      const AddTransactionScreen(),
                ),
              );

              if (!mounted) return;

              await refreshDashboard();
            },
          ),
          const SizedBox(width: 8),
        ],
      ),

      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: [
              Color(0xFFB6D7CC),
              Color(0xFFDAEDE5),
              Color(0xFFF8FCFA),
            ],
            stops: [0.0, 0.52, 1.0],
          ),
        ),
        child: RefreshIndicator(
          onRefresh: refreshDashboard,
            child: CustomScrollView(

            physics:
                const AlwaysScrollableScrollPhysics(),

            slivers: [

              // =========================================
              // SUMMARY CARDS
              // =========================================

              SliverToBoxAdapter(

                child: Padding(

                  padding:
                      const EdgeInsets.all(
                    12,
                  ),

                  child: Row(

                    children: [

                      Expanded(

                        child: SummaryCard(

                          title:
                              'Income',

                          amount:
                            CurrencyFormatter.format(

                            amount: income,

                            currency: currency,
                          ),

                          icon:
                              Icons
                                  .trending_up,
                          variant: SummaryCardVariant.income,
                        ),
                      ),

                      const SizedBox(
                        width: 8,
                      ),

                      Expanded(

                        child: SummaryCard(

                          title:
                              'Expense',

                          amount:
                            CurrencyFormatter.format(

                            amount: expense,

                            currency: currency,
                          ),

                          icon:
                              Icons
                                  .trending_down,
                          variant: SummaryCardVariant.expense,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // =========================================
              // BALANCE CARD
              // =========================================

              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                  ),
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(18),
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Color(0xFF103D39),
                          Color(0xFF176C61),
                          Color(0xFF4BA88B),
                        ],
                        stops: [0.0, 0.55, 1.0],
                      ),
                      border: Border.all(
                        color: Colors.white.withValues(
                          alpha: 0.55,
                        ),
                        width: 1.2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF0D6D60)
                              .withValues(alpha: 0.24),
                          blurRadius: 18,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(18),
                      child: Stack(
                        children: [
                          Positioned(
                            top: -55,
                            right: -25,
                            child: Container(
                              width: 170,
                              height: 170,
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: RadialGradient(
                                  colors: [
                                    Color(0x66FFFFFF),
                                    Color(0x00FFFFFF),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 16,
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.center,
                                  children: [
                                    const Icon(
                                      Icons.account_balance_wallet_outlined,
                                      color: Color(0xFFE2FFF2),
                                      size: 19,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Total Balance',
                                      style: TextStyle(
                                        color: Colors.white.withValues(
                                          alpha: 0.95,
                                        ),
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                SizedBox(
                                  width: double.infinity,
                                  child: FittedBox(
                                    fit: BoxFit.scaleDown,
                                    child: Text(
                                      CurrencyFormatter.format(
                                        amount: balance,
                                        currency: currency,
                                      ),
                                      maxLines: 1,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 30,
                                        fontWeight: FontWeight.w800,
                                        letterSpacing: -0.5,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),


              // =========================================
              // FINANCIAL GOALS
              // =========================================

              const SliverToBoxAdapter(

                child: Padding(

                  padding: EdgeInsets.fromLTRB(
                    12,
                    10,
                    12,
                    0,
                  ),

                  child: GoalsSummaryCard(auroraStyle: true,),
                ),
              ),

              // =========================================
              // INSIGHTS
              // =========================================

              SliverToBoxAdapter(

                child: Padding(

                  padding:
                      const EdgeInsets.fromLTRB(
                    12,
                    10,
                    12,
                    0,
                  ),

                  child: insightsAsync.when(

                    data: (insights) {

                      return DashboardInsightsSection(
                        insights:
                            insights,
                      );
                    },

                    error: (_, _) =>
                      const SizedBox(),

                    loading: () =>

                        const Center(

                      child:
                          Padding(

                        padding:
                            EdgeInsets.all(
                          24,
                        ),

                        child:
                            CircularProgressIndicator(),
                      ),
                    ),
                  ),
                ),
              ),

              // =========================================
              // RECENT TRANSACTIONS HEADER
              // =========================================

              const SliverToBoxAdapter(

                child: Padding(

                  padding:
                      EdgeInsets.fromLTRB(
                    16,
                    10,
                    16,
                    8,
                  ),

                  child: Text(

                    'Recent Transactions',

                    style: TextStyle(

                      fontSize: 18,

                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),
                ),
              ),

              // =========================================
              // TRANSACTION LIST
              // =========================================

              const SliverToBoxAdapter(
                child: TransactionListScreen(
                  defaultLimit: 3,
                  auroraStyle: true,
                  scrollWithParent: true,
                ),
              ),

            ],
          ),
        ),
      ),

      // floatingActionButton:
      //     FloatingActionButton(

      //   heroTag:
      //       'dashboard_fab',

      //   onPressed: () async {

      //     await Navigator.push(
      //       context,
      //       MaterialPageRoute(
      //         builder: (_) =>
      //             const AddTransactionScreen(),
      //       ),
      //     );

      //     if (!mounted) return;

      //     await refreshDashboard();
      //   },

      //   child: const Icon(
      //     Icons.add,
      //   ),
      // ),
    );
  }
}
