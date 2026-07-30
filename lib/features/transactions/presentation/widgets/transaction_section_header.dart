import 'package:flutter/material.dart';

class TransactionSectionHeader extends StatelessWidget {

  const TransactionSectionHeader({

    super.key,

    required this.title,
  });

  final String title;

  @override
  Widget build(BuildContext context) {

    return Container(

      width: double.infinity,

      margin: const EdgeInsets.only(

        top: 12,

        left: 12,

        right: 12,

        bottom: 4,
      ),

      padding: const EdgeInsets.symmetric(

        horizontal: 16,

        vertical: 10,
      ),

      decoration: BoxDecoration(

        color: Theme.of(context)
            .colorScheme
            .surfaceContainerHighest,

        borderRadius:
            BorderRadius.circular(
          12,
        ),
      ),

      child: Text(

        title,

        style: Theme.of(context)
            .textTheme
            .titleMedium
            ?.copyWith(

              fontWeight:
                  FontWeight.bold,
            ),
      ),
    );
  }
}