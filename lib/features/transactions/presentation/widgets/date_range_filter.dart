import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../dashboard/presentation/providers/transaction_filter_provider.dart';


class DateRangeFilter extends ConsumerWidget {

  const DateRangeFilter({
    super.key,
  });

  Future<void> _selectFromDate(
    BuildContext context,
    WidgetRef ref,
    DateTime? currentDate,
  ) async {

    final picked = await showDatePicker(

      context: context,

      initialDate:
          currentDate ?? DateTime.now(),

      firstDate:
          DateTime(2000),

      lastDate:
          DateTime(2100),
    );

    if (picked != null) {

      ref
          .read(
            transactionFilterProvider.notifier,
          )
          .setFromDate(
            picked,
          );
    }
  }

  Future<void> _selectToDate(
    BuildContext context,
    WidgetRef ref,
    DateTime? currentDate,
  ) async {

    final picked = await showDatePicker(

      context: context,

      initialDate:
          currentDate ?? DateTime.now(),

      firstDate:
          DateTime(2000),

      lastDate:
          DateTime(2100),
    );

    if (picked != null) {

      ref
          .read(
            transactionFilterProvider.notifier,
          )
          .setToDate(
            picked,
          );
    }
  }

  @override
  Widget build(
    BuildContext context,
    WidgetRef ref,
  ) {

    final filter =
        ref.watch(
      transactionFilterProvider,
    );

    return Column(

      crossAxisAlignment:
          CrossAxisAlignment.start,

      children: [

        const Text(

          'Date Range',

          style: TextStyle(

            fontWeight:
                FontWeight.bold,
          ),
        ),

        const SizedBox(
          height: 12,
        ),

        Row(

          children: [

            Expanded(

              child: OutlinedButton.icon(

                icon:
                    const Icon(
                  Icons.calendar_today,
                ),

                label: Text(

                  filter.fromDate == null

                      ? 'From'

                      : DateFormat(
                          'dd MMM yyyy',
                        ).format(
                          filter.fromDate!,
                        ),
                ),

                onPressed: () {

                  _selectFromDate(

                    context,

                    ref,

                    filter.fromDate,
                  );
                },
              ),
            ),

            const SizedBox(
              width: 12,
            ),

            Expanded(

              child: OutlinedButton.icon(

                icon:
                    const Icon(
                  Icons.calendar_today,
                ),

                label: Text(

                  filter.toDate == null

                      ? 'To'

                      : DateFormat(
                          'dd MMM yyyy',
                        ).format(
                          filter.toDate!,
                        ),
                ),

                onPressed: () {

                  _selectToDate(

                    context,

                    ref,

                    filter.toDate,
                  );
                },
              ),
            ),
          ],
        ),
      ],
    );
  }
}