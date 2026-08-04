import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:async';

import '../providers/transaction_filter_provider.dart';

class TransactionSearchBar extends ConsumerStatefulWidget {

  const TransactionSearchBar({
    super.key,
  });

  @override
  ConsumerState<TransactionSearchBar> createState() =>
      _TransactionSearchBarState();
}

class _TransactionSearchBarState
    extends ConsumerState<TransactionSearchBar> {

  late final TextEditingController _controller;
  Timer? _debounce;

  @override
  void initState() {

    super.initState();

    _controller = TextEditingController(
      text: ref.read(
        transactionFilterProvider,
      ).searchText,
    );
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(
    BuildContext context,
  ) {

    final filter =
        ref.watch(
      transactionFilterProvider,
    );

    // Keep controller synchronized when filter changes externally.
    if (_controller.text != filter.searchText) {

      _controller.value = TextEditingValue(

        text: filter.searchText,

        selection: TextSelection.collapsed(
          offset: filter.searchText.length,
        ),
      );
    }

    return TextField(

      controller: _controller,

      textInputAction: TextInputAction.search,

      decoration: InputDecoration(

        hintText: 'Search transactions...',

        prefixIcon: const Icon(
          Icons.search,
        ),

        suffixIcon: filter.searchText.isEmpty

            ? null

            : IconButton(

                icon: const Icon(
                  Icons.clear,
                ),

                onPressed: () {

                  _controller.clear();

                  ref
                      .read(
                        transactionFilterProvider.notifier,
                      )
                      .setSearchText('');
                },
              ),

        filled: true,

        fillColor:
            Theme.of(context)
                .colorScheme
                .surfaceContainerHighest,

        contentPadding:
            const EdgeInsets.symmetric(

          horizontal: 16,

          vertical: 14,
        ),

        border: OutlineInputBorder(

          borderRadius:
              BorderRadius.circular(
            12,
          ),

          borderSide:
              BorderSide.none,
        ),

        enabledBorder: OutlineInputBorder(

          borderRadius:
              BorderRadius.circular(
            12,
          ),

          borderSide:
              BorderSide.none,
        ),

        focusedBorder: OutlineInputBorder(

          borderRadius:
              BorderRadius.circular(
            12,
          ),

          borderSide: BorderSide(

            color: Theme.of(context)
                .colorScheme
                .primary,

            width: 1.5,
          ),
        ),
      ),

      // onChanged: (value) {

      //   ref
      //       .read(
      //         transactionFilterProvider.notifier,
      //       )
      //       .setSearchText(
      //         value,
      //       );
      // },
      onChanged: (value) {
        _debounce?.cancel();
        _debounce = Timer(
          const Duration(
            milliseconds: 300,
          ),
          () {
            ref.read(
              transactionFilterProvider.notifier,
            )
            .setSearchText(
              value,
            );
          },
        );
      },
    );
  }
}