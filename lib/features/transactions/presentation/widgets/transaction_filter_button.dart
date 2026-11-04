import 'package:flutter/material.dart';

import 'transaction_filter_bottom_sheet.dart';

class TransactionFilterButton extends StatelessWidget {

  const TransactionFilterButton({
    super.key,
  });

  @override
  Widget build(BuildContext context) {

    return Align(

      alignment: Alignment.centerRight,

      child: OutlinedButton.icon(

        icon: const Icon(
          Icons.filter_alt_outlined,
        ),

        label: const Text(
          'Advanced Filters',
        ),

        onPressed: () {
          final screenHeight = MediaQuery.sizeOf(context).height;

          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            useSafeArea: true,
            showDragHandle: true,
            constraints: BoxConstraints(
              maxHeight: screenHeight * 0.9,
            ),
            builder: (sheetContext) {
              return Padding(
                padding: EdgeInsets.only(
                  bottom: MediaQuery.viewInsetsOf(sheetContext).bottom,
                ),
                child: const TransactionFilterBottomSheet(),
              );
            },
          );
        },
      ),
    );
  }
}