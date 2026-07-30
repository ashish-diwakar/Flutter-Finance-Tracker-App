import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../dashboard/presentation/providers/transaction_filter_provider.dart';
import 'account_filter_dropdown.dart';
import 'category_filter_dropdown.dart';
import 'date_range_filter.dart';

class TransactionFilterBottomSheet
    extends ConsumerWidget {

  const TransactionFilterBottomSheet({

    super.key,

    required this.scrollController,
  });

  final ScrollController scrollController;


  @override
  @override
  Widget build(
    BuildContext context,
    WidgetRef ref,
  ) {

    return SafeArea(

      child: SingleChildScrollView(
        controller: scrollController,

        padding: const EdgeInsets.all(20),

        child: Column(

          crossAxisAlignment:
              CrossAxisAlignment.start,

          children: [

              // ==========================================================
              // HEADER
              // ==========================================================

              Row(

                children: [

                  Icon(

                    Icons.filter_alt_rounded,

                    color: Theme.of(context)
                        .colorScheme
                        .primary,

                    size: 28,
                  ),

                  const SizedBox(
                    width: 12,
                  ),

                  Text(

                    'Advanced Filters',

                    style: Theme.of(context)
                        .textTheme
                        .headlineSmall
                        ?.copyWith(

                          fontWeight:
                              FontWeight.bold,
                        ),
                  ),
                ],
              ),

              // const SizedBox(
              //   height: 24,
              // ),

              // ==========================================================
              // ACCOUNT
              // ==========================================================

              const Card(

                elevation: 0,

                child: Padding(

                  padding: EdgeInsets.all(16),

                  child: Column(

                    crossAxisAlignment:
                        CrossAxisAlignment.start,

                    children: [AccountFilterDropdown()],
                  ),
                ),
              ),

              // const SizedBox(
              //   height: 16,
              // ),

              // ==========================================================
              // CATEGORY
              // ==========================================================

              const Card(

                elevation: 0,

                child: Padding(

                  padding: EdgeInsets.all(16),

                  child: Column(

                    crossAxisAlignment:
                        CrossAxisAlignment.start,

                    children: [
                      CategoryFilterDropdown(),
                    ],
                  ),
                ),
              ),

              // const SizedBox(
              //   height: 16,
              // ),

              // ==========================================================
              // DATE RANGE
              // ==========================================================

              const Card(

                elevation: 0,

                child: Padding(

                  padding: EdgeInsets.all(16),

                  child: Column(

                    crossAxisAlignment:
                        CrossAxisAlignment.start,

                    children: [

                      // Text(

                      //   'Date Range',

                      //   style: Theme.of(context)
                      //       .textTheme
                      //       .titleMedium
                      //       ?.copyWith(

                      //         fontWeight:
                      //             FontWeight.w600,
                      //       ),
                      // ),

                      // const SizedBox(
                      //   height: 12,
                      // ),

                      DateRangeFilter(),
                    ],
                  ),
                ),
              ),

              const SizedBox(
                height: 28,
              ),

              // ==========================================================
              // ACTION BUTTONS
              // ==========================================================

              Row(

                children: [

                  Expanded(

                    child: OutlinedButton.icon(

                      icon: const Icon(
                        Icons.refresh,
                      ),

                      label: const Text(
                        'Reset',
                      ),

                      style: OutlinedButton.styleFrom(

                        minimumSize:
                            const Size.fromHeight(
                          48,
                        ),
                      ),

                      onPressed: () {

                        ref
                            .read(
                              transactionFilterProvider.notifier,
                            )
                            .clearFilters();
                      },
                    ),
                  ),

                  const SizedBox(
                    width: 12,
                  ),

                  Expanded(

                    child: FilledButton.icon(

                      icon: const Icon(
                        Icons.close,
                      ),

                      label: const Text(
                        'Close',
                      ),

                      style: FilledButton.styleFrom(

                        minimumSize:
                            const Size.fromHeight(
                          48,
                        ),
                      ),

                      onPressed: () {

                        Navigator.pop(
                          context,
                        );
                      },
                    ),
                  ),
                ],
              ),

              // const SizedBox(
              //   height: 20,
              // ),
            ],
        ),
      ),
    );
  }
}