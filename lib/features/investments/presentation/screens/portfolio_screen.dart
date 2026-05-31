import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/utils/currency_formatter.dart';
import '../../../../shared/providers/currency_provider.dart';
import '../../../../shared/models/investment_model.dart';

import '../providers/investments_provider.dart';
import '../providers/investment_analytics_provider.dart';

import '../widgets/portfolio_summary_card.dart';
import 'add_investment_screen.dart';
import 'edit_investment_screen.dart';

class PortfolioScreen
    extends ConsumerStatefulWidget {

  const PortfolioScreen({
    super.key,
  });

  @override
  ConsumerState<PortfolioScreen>
      createState() =>
          _PortfolioScreenState();
}

class _PortfolioScreenState
    extends ConsumerState<
        PortfolioScreen> {

  bool isSyncing = false;

  Future<void>
      syncAllInvestments()
  async {

    if (isSyncing) return;

    setState(() {
      isSyncing = true;
    });

    try {
      final syncedCount =
          await ref.read(investmentSyncProvider).syncAllInvestments();

      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(
          SnackBar(
            content: Text(
              '$syncedCount investments synced successfully',
            ),
          ),
        );
      }
    } catch (e, stackTrace) {
      debugPrint('Sync failed: $e');
      debugPrint('StackTrace: $stackTrace');

      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(
          SnackBar(
            content: Text(
              'Sync failed: $e',
            ),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          isSyncing = false;
        });
      }
    }
  }

  @override
  Widget build(
    BuildContext context,
  ) {

    final analyticsAsync =
        ref.watch(
      investmentAnalyticsProvider,
    );

    final investmentsAsync =
        ref.watch(
      investmentsProvider,
    );

    final currency =
        ref.watch(
      currencyProvider,
    );

    return Scaffold(

      appBar: AppBar(

        title: const Text(
          'Investments',
        ),

        actions: [

          IconButton(

            tooltip:
                'Sync All',

            onPressed:

                isSyncing

                    ? null

                    : syncAllInvestments,

            icon:

                isSyncing

                    ? const SizedBox(

                        width: 20,
                        height: 20,

                        child:
                            CircularProgressIndicator(
                          strokeWidth: 2,
                        ),
                      )

                    : const Icon(
                        Icons.sync,
                      ),
          ),
        ],
      ),

      floatingActionButton:
          FloatingActionButton(

        heroTag:
            'portfolio_add_investment',

        onPressed: () async {

          final result =
              await Navigator.push(

            context,

            MaterialPageRoute(

              builder: (_) =>
                  const AddInvestmentScreen(),
            ),
          );

          if (result == true) {

            ref.invalidate(
              investmentsProvider,
            );

            ref.invalidate(
              investmentAnalyticsProvider,
            );
          }
        },

        child: const Icon(
          Icons.add,
        ),
      ),

      body: RefreshIndicator(

        onRefresh: () async {

          ref.invalidate(
            investmentsProvider,
          );

          ref.invalidate(
            investmentAnalyticsProvider,
          );
        },

        child: ListView(

          padding:
              const EdgeInsets.all(
            16,
          ),

          children: [

            // ====================================
            // PORTFOLIO SUMMARY
            // ====================================

            analyticsAsync.when(

              data: (analytics) {

                return PortfolioSummaryCard(
                  analytics: analytics,
                );
              },

              loading: () =>

                  const Card(

                child: Padding(

                  padding:
                      EdgeInsets.all(
                    24,
                  ),

                  child: Center(

                    child:
                        CircularProgressIndicator(),
                  ),
                ),
              ),

              error: (_, __) =>

                  const Card(

                child: Padding(

                  padding:
                      EdgeInsets.all(
                    16,
                  ),

                  child: Text(
                    'Unable to load portfolio analytics',
                  ),
                ),
              ),
            ),

            const SizedBox(
              height: 24,
            ),

            // ====================================
            // HOLDINGS HEADER
            // ====================================

            const Text(

              'Holdings',

              style: TextStyle(

                fontSize: 20,

                fontWeight:
                    FontWeight.bold,
              ),
            ),

            const SizedBox(
              height: 8,
            ),

            Text(

              'Track your investment portfolio and performance.',

              style: TextStyle(

                color:
                    Colors.grey.shade600,
              ),
            ),

            const SizedBox(
              height: 16,
            ),

            // ====================================
            // HOLDINGS LIST
            // ====================================

            investmentsAsync.when(

              data: (investments) {

                if (investments
                    .isEmpty) {

                  return Card(

                    child: Padding(

                      padding:
                          const EdgeInsets.all(
                        24,
                      ),

                      child: Column(

                        children: [

                          const Icon(

                            Icons
                                .trending_up,

                            size: 64,
                          ),

                          const SizedBox(
                            height: 16,
                          ),

                          const Text(

                            'No Investments Yet',

                            style:
                                TextStyle(

                              fontSize: 18,

                              fontWeight:
                                  FontWeight
                                      .bold,
                            ),
                          ),

                          const SizedBox(
                            height: 8,
                          ),

                          Text(

                            'Add your first investment to start tracking portfolio performance.',

                            textAlign:
                                TextAlign
                                    .center,

                            style:
                                TextStyle(

                              color: Colors
                                  .grey
                                  .shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                return Column(

                  children:

                      investments
                          .map(

                    (investment) {

                      return Padding(

                        padding:
                            const EdgeInsets.only(
                          bottom: 12,
                        ),

                        child: InkWell(

                          borderRadius:
                              BorderRadius.circular(
                            12,
                          ),

                          onTap: () async {

                            final result =
                                await Navigator.push(

                              context,

                              MaterialPageRoute(

                                builder: (_) =>
                                    EditInvestmentScreen(
                                  investment:
                                      investment,
                                ),
                              ),
                            );

                            if (result == true) {

                              ref.invalidate(
                                investmentsProvider,
                              );

                              ref.invalidate(
                                investmentAnalyticsProvider,
                              );
                            }
                          },

                          child: _InvestmentCard(

                            investment:
                                investment,

                            currency:
                                currency,
                          ),
                        ),
                      );
                    },
                  ).toList(),
                );
              },

              loading: () =>

                  const Padding(

                padding:
                    EdgeInsets.all(
                  24,
                ),

                child: Center(

                  child:
                      CircularProgressIndicator(),
                ),
              ),

              error: (_, __) =>

                  const Card(

                child: Padding(

                  padding:
                      EdgeInsets.all(
                    16,
                  ),

                  child: Text(
                    'Unable to load investments',
                  ),
                ),
              ),
            ),

            const SizedBox(
              height: 100,
            ),
          ],
        ),
      ),
    );
  }
}

class _InvestmentCard
    extends StatelessWidget {

  final InvestmentModel
      investment;

  final dynamic currency;

  const _InvestmentCard({

    required this.investment,

    required this.currency,
  });

  @override
  Widget build(
    BuildContext context,
  ) {

    final isFixedReturn = [

      'FD',
      'RD',
      'PPF',
      'EPF',
      'NPS',
      'Bond',

    ].contains(
      investment.type,
    );

    final investedValue =

        (investment.quantity *
                investment.purchasePrice) /
            100;

    final currentValue =

        isFixedReturn

            ? ((investment.maturityValue ??
                        investment.purchasePrice) /
                    100)

            : ((investment.quantity *
                        investment.currentPrice) /
                    100);

    final profitLoss =
        currentValue -
            investedValue;

    final isProfit =
        profitLoss >= 0;

    return Card(

      child: Padding(

        padding:
            const EdgeInsets.all(
          16,
        ),

        child: Column(

          crossAxisAlignment:
              CrossAxisAlignment
                  .start,

          children: [

            Row(

              children: [

                CircleAvatar(

                  child: Text(

                    investment.name
                        .substring(
                      0,
                      1,
                    )
                        .toUpperCase(),
                  ),
                ),

                const SizedBox(
                  width: 12,
                ),

                Expanded(

                  child: Column(

                    crossAxisAlignment:
                        CrossAxisAlignment
                            .start,

                    children: [

                      Text(

                        investment.name,

                        style:
                            const TextStyle(

                          fontSize: 16,

                          fontWeight:
                              FontWeight
                                  .bold,
                        ),
                      ),

                      Text(

                        investment.type,

                        style:
                            TextStyle(

                          color: Colors
                              .grey
                              .shade600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(
              height: 16,
            ),

            if (!isFixedReturn)

              Row(

                mainAxisAlignment:
                    MainAxisAlignment
                        .spaceBetween,

                children: [

                  const Text(
                    'Quantity',
                  ),

                  Text(
                    investment.quantity
                        .toString(),
                  ),
                ],
              )

            else

              Row(

                mainAxisAlignment:
                    MainAxisAlignment
                        .spaceBetween,

                children: [

                  const Text(
                    'Interest Rate',
                  ),

                  Text(
                    '${investment.interestRate ?? 0}%',
                  ),
                ],
              ),

            const SizedBox(
              height: 8,
            ),

            Row(

              mainAxisAlignment:
                  MainAxisAlignment
                      .spaceBetween,

              children: [

                const Text(
                  'Invested',
                ),

                Text(

                  CurrencyFormatter
                      .formatDouble(

                    amount:
                        investedValue,

                    currency:
                        currency,
                  ),
                ),
              ],
            ),

            const SizedBox(
              height: 8,
            ),

            Row(

              mainAxisAlignment:
                  MainAxisAlignment
                      .spaceBetween,

              children: [

                Text(

                  isFixedReturn

                      ? 'Maturity Value'

                      : 'Current Value',
                ),

                if (isFixedReturn &&
                    investment.maturityDate != null)
                  ...[

                    const SizedBox(
                      height: 8,
                    ),

                    Row(

                      mainAxisAlignment:
                          MainAxisAlignment
                              .spaceBetween,

                      children: [

                        const Text(
                          'Maturity Date',
                        ),

                        Text(

                          '${investment.maturityDate!.day}/'
                          '${investment.maturityDate!.month}/'
                          '${investment.maturityDate!.year}',
                        ),
                      ],
                    ),
                  ],

                Text(

                  CurrencyFormatter
                      .formatDouble(

                    amount:
                        currentValue,

                    currency:
                        currency,
                  ),
                ),
              ],
            ),

            const Divider(
              height: 24,
            ),

            Row(

              mainAxisAlignment:
                  MainAxisAlignment
                      .spaceBetween,

              children: [

                const Text(
                  'Profit / Loss',
                ),

                Text(

                  CurrencyFormatter
                      .formatDouble(

                    amount:
                        profitLoss,

                    currency:
                        currency,
                  ),

                  style: TextStyle(

                    color:

                        isProfit

                            ? Colors.green

                            : Colors.red,

                    fontWeight:
                        FontWeight.bold,
                  ),
                ),
              ],
            ),

            if (investment.notes !=
                    null &&
                investment
                    .notes!
                    .trim()
                    .isNotEmpty) ...[

              const SizedBox(
                height: 12,
              ),

              Text(

                investment.notes!,

                style: TextStyle(

                  color: Colors
                      .grey.shade600,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}