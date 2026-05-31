import 'package:finance_tracker/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/widgets/summary_card.dart';
import '../../../transactions/presentation/screens/add_transaction_screen.dart';
import '../../../transactions/presentation/screens/transaction_list_screen.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../auth/presentation/screens/login_screen.dart';
import '../../../sync/presentation/providers/sync_provider.dart';
import '../providers/balance_provider.dart';
import '../providers/expense_provider.dart';
import '../providers/income_provider.dart';
import '../providers/transactions_provider.dart';
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

      final syncService =
          await ref.read(
        syncServiceProvider.future,
      );

      await syncService
          .syncAll();

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

      ref.invalidate(
        dashboardInsightsProvider,
      );

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(

        const SnackBar(

          content: Text(
            'Sync completed successfully',
          ),
        ),
      );

    } catch (e, stackTrace) {

        logger.d(
          'Sync Error: $e',
        );
        logger.d(
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

    ref.invalidate(
      dashboardInsightsProvider,
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
            ) ??
            0;

    final appName =
        dotenv.env['APP_NAME'] ??
            'Finance Tracker';

    final insightsAsync =
        ref.watch(
      dashboardInsightsProvider,
    );

    final currency =
        ref.watch(
      currencyProvider,
    );

    return Scaffold(

      appBar: AppBar(

        centerTitle: false,

        title: Text(
          appName,
        ),

        actions: [

          IconButton(

            onPressed:
                syncing
                    ? null
                    : syncData,

            icon: syncing

                ? const SizedBox(

                    height: 20,
                    width: 20,

                    child:
                        CircularProgressIndicator(
                      strokeWidth: 2,
                    ),
                  )

                : const Icon(
                    Icons.sync,
                  ),
          ),

          IconButton(

            onPressed: () async {

              final auth =
                  ref.read(
                authServiceProvider,
              );

              await auth
                  .signOut();

              if (!context.mounted) {
                return;
              }

              Navigator.pushAndRemoveUntil(

                context,

                MaterialPageRoute(

                  builder: (_) =>
                      const LoginScreen(),
                ),

                (route) => false,
              );
            },

            icon: const Icon(
              Icons.logout,
            ),
          ),
        ],
      ),

      body: RefreshIndicator(

        onRefresh:
            refreshDashboard,

        child:
            CustomScrollView(

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

                padding:
                    const EdgeInsets.symmetric(
                  horizontal: 12,
                ),

                child: Card(

                  child: Padding(

                    padding:
                        const EdgeInsets.all(
                      20,
                    ),

                    child: Column(

                      children: [

                        const Text(

                          'Total Balance',

                          style: TextStyle(

                            fontWeight:
                                FontWeight.bold,

                            fontSize: 16,
                          ),
                        ),

                        const SizedBox(
                          height: 16,
                        ),

                        Text(

                          CurrencyFormatter.format(

                          amount: balance,

                          currency: currency,
                        ),

                          style:
                              const TextStyle(

                            fontSize: 32,

                            fontWeight:
                                FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
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
                  20,
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

                  error: (_, __) =>

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
                  20,
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

            SliverToBoxAdapter(
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  maxHeight: 300, // 🔥 Set your maximum height here
                ),
                child: const Padding(
                  padding: EdgeInsets.only(
                    bottom: 20,
                  ),
                  child: TransactionListScreen(
                    defaultLimit: 3,
                  ),
                ),
              ),
            ),

          ],
        ),
      ),

      floatingActionButton:
          FloatingActionButton(

        heroTag:
            'dashboard_fab',

        onPressed: () {

          Navigator.push(

            context,

            MaterialPageRoute(

              builder: (_) =>
                  const AddTransactionScreen(),
            ),
          );
        },

        child: const Icon(
          Icons.add,
        ),
      ),
    );
  }
}
