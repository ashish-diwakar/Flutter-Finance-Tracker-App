import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/services/logger_service.dart';
import '../../../../shared/utils/provider_refresh_helper.dart';
import '../../../transactions/presentation/screens/add_transaction_screen.dart';
import '../../../transactions/presentation/screens/transaction_list_screen.dart';
import '../providers/transaction_filter_provider.dart';
import '../widgets/transaction_filter_button.dart';
import '../widgets/transaction_summary_card.dart';

class TransactionListContainerScreen extends ConsumerStatefulWidget {
  const TransactionListContainerScreen({super.key});

  @override
  ConsumerState<TransactionListContainerScreen> createState() =>
      _TransactionListContainerScreenState();
}

class _TransactionListContainerScreenState
    extends ConsumerState<TransactionListContainerScreen> {
  bool syncing = false;

  Future<void> syncData() async {
    setState(() {
      syncing = true;
    });

    try {
      // Commented Sync
      // final syncService = await ref.read(
      //   syncServiceProvider.future,
      // );

      // await syncService.syncAll();

      await ProviderRefreshHelper.refreshTransactionData(ref);

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Sync completed'),
        ),
      );
    } catch (e, stackTrace) {
      // FIXED: Properly passing String types to your LoggerService methods
      LoggerService.error('Sync Error: $e');
      LoggerService.error('Stack Trace: $stackTrace');
        
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Unable to sync. Please try again.'),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
            
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Transactions'),
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
                  builder: (_) => const AddTransactionScreen(),
                ),
              );

              if (!mounted) return;

              await ProviderRefreshHelper.refreshTransactionData(
                ref,
              );
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
        child: NestedScrollView(
          headerSliverBuilder: (context, innerBoxIsScrolled) {
            return [
              SliverToBoxAdapter(
                child: Column(
                  children: [
                    const SizedBox(height: 8),

                    // Aurora filter panel
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                      ),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.fromLTRB(
                          12,
                          10,
                          12,
                          10,
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(18),
                          gradient: const LinearGradient(
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                            colors: [
                              Color(0xFFD1EFDE),
                              Color(0xFFEAF8F0),
                              Color(0xFFF5FCF8),
                            ],
                          ),
                          border: Border.all(
                            color: Colors.white.withValues(
                              alpha: 0.85,
                            ),
                            width: 1,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF24795F)
                                  .withValues(alpha: 0.10),
                              blurRadius: 12,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: const Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.tune_rounded,
                                  size: 18,
                                  color: Color(0xFF175D46),
                                ),
                                SizedBox(width: 8),
                                Text(
                                  'Show',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF285544),
                                  ),
                                ),
                                SizedBox(width: 8),
                                _LimitDropdown(),
                              ],
                            ),
                            SizedBox(height: 8),
                            _TypeFilterChips(),
                            SizedBox(height: 8),
                            TransactionFilterButton(),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 8),

                    // Aurora financial summary
                    const TransactionSummaryCard(),

                    const SizedBox(height: 8),
                  ],
                ),
              ),
            ];
          },

          // The existing list remains independently
          // lazy-built and works with NestedScrollView.
          body: const TransactionListScreen(
            auroraStyle: true,
            scrollWithParent: false,
          ),
        ), // NestedScrollView
      ),   // DecoratedBox

    );
  }
}

class _LimitDropdown extends ConsumerWidget {

  const _LimitDropdown();

  @override
  Widget build(
    BuildContext context,
    WidgetRef ref,
  ) {

    final filter =
        ref.watch(
      transactionFilterProvider,
    );

    return DropdownButtonHideUnderline(

      child: DropdownButton<TransactionLimit>(

        value: filter.limit,

        isDense: true,

        borderRadius:
            BorderRadius.circular(
          12,
        ),

        icon: const Icon(
          Icons.expand_more,
        ),

        onChanged: (value) {

          if (value == null) {
            return;
          }

          ref
              .read(
                transactionFilterProvider.notifier,
              )
              .setLimit(
                value,
              );
        },

        items: TransactionLimit.values

            .map(

              (limit) => DropdownMenuItem(

                value: limit,

                child: Text(
                  limit.label,
                ),
              ),
            )

            .toList(),
      ),
    );
  }
}

class _TypeFilterChips extends ConsumerWidget {

  const _TypeFilterChips();

  @override
  Widget build(
    BuildContext context,
    WidgetRef ref,
  ) {

    final filter =
        ref.watch(
      transactionFilterProvider,
    );

    return SingleChildScrollView(

      scrollDirection:
          Axis.horizontal,

      child: Row(

        children:

            TransactionTypeFilter.values

                .map(

                  (type) => Padding(

                    padding:
                        const EdgeInsets.only(
                      right: 8,
                    ),

                    child: ChoiceChip(

                      label:
                          Text(
                        type.label,
                      ),

                      selected:
                          filter.type ==
                          type,

                      showCheckmark:
                          false,

                      onSelected: (_) {

                        ref
                            .read(
                              transactionFilterProvider.notifier,
                            )
                            .setType(
                              type,
                            );
                      },
                    ),
                  ),
                )

                .toList(),
      ),
    );
  }
}

class TransactionFilter {

  const TransactionFilter({

    this.limit = TransactionLimit.last10,

    this.type = TransactionTypeFilter.all,

    this.searchText = '',
  });

  final TransactionLimit limit;

  final TransactionTypeFilter type;

  final String searchText;

  TransactionFilter copyWith({

    TransactionLimit? limit,

    TransactionTypeFilter? type,

    String? searchText,
  }) {

    return TransactionFilter(

      limit: limit ?? this.limit,

      type: type ?? this.type,

      searchText:
          searchText ?? this.searchText,
    );
  }
}