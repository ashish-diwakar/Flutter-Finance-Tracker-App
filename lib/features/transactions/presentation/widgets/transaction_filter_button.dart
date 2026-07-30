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

          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            useSafeArea: true,
            showDragHandle: true,
            builder: (_) {
              return DraggableScrollableSheet(
                expand: false,
                initialChildSize: 0.80,
                minChildSize: 0.60,
                maxChildSize: 0.95,
                builder: (context, scrollController) {
                  return TransactionFilterBottomSheet(
                    scrollController:
                        scrollController,
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}