import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../providers/transaction_filter_provider.dart';

class DateRangeFilter extends ConsumerWidget {
  const DateRangeFilter({super.key});

  Future<void> _selectFromDate(
    BuildContext context,
    WidgetRef ref,
    DateTime? currentDate,
  ) async {
    final picked = await showDatePicker(
      context: context,

      initialDate: currentDate ?? DateTime.now(),

      firstDate: DateTime(2000),

      lastDate: DateTime(2100),
    );

    if (picked != null) {
      ref.read(transactionFilterProvider.notifier).setFromDate(picked);
    }
  }

  Future<void> _selectToDate(
    BuildContext context,
    WidgetRef ref,
    DateTime? currentDate,
  ) async {
    final picked = await showDatePicker(
      context: context,

      initialDate: currentDate ?? DateTime.now(),

      firstDate: DateTime(2000),

      lastDate: DateTime(2100),
    );

    if (picked != null) {
      ref.read(transactionFilterProvider.notifier).setToDate(picked);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filter = ref.watch(transactionFilterProvider);

    final fromButton = OutlinedButton.icon(
      icon: const Icon(Icons.calendar_today, size: 20),
      label: Text(
        filter.fromDate == null
            ? 'From'
            : DateFormat('dd MMM yyyy').format(filter.fromDate!),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      style: OutlinedButton.styleFrom(
        foregroundColor: const Color(0xFF315F53),
        minimumSize: const Size.fromHeight(48),
        textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
        side: const BorderSide(color: Color(0xFF9ABBAB)),
      ),
      onPressed: () {
        _selectFromDate(context, ref, filter.fromDate);
      },
    );

    final toButton = OutlinedButton.icon(
      icon: const Icon(Icons.calendar_today, size: 20),
      label: Text(
        filter.toDate == null
            ? 'To'
            : DateFormat('dd MMM yyyy').format(filter.toDate!),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      style: OutlinedButton.styleFrom(
        foregroundColor: const Color(0xFF315F53),
        minimumSize: const Size.fromHeight(48),
        textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
        side: const BorderSide(color: Color(0xFF9ABBAB)),
      ),
      onPressed: () {
        _selectToDate(context, ref, filter.toDate);
      },
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Date Range',
          style: TextStyle(
            color: Color(0xFF315F53),
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        LayoutBuilder(
          builder: (context, constraints) {
            final scaledButtonWidth = MediaQuery.textScalerOf(
              context,
            ).scale(150);
            if (constraints.maxWidth < scaledButtonWidth * 2 + 12) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [fromButton, const SizedBox(height: 8), toButton],
              );
            }

            return Row(
              children: [
                Expanded(child: fromButton),
                const SizedBox(width: 12),
                Expanded(child: toButton),
              ],
            );
          },
        ),
      ],
    );
  }
}
