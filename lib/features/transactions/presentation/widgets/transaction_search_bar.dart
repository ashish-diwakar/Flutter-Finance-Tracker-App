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

      style: const TextStyle(
        color: Color(0xFF244C40),
        fontSize: 16,
      ),

      decoration: InputDecoration(
        hintText: 'Search transactions...',
        hintStyle: const TextStyle(
          color: Color(0xFF6C8A80),
          fontSize: 16,
        ),

        prefixIcon: const Icon(
          Icons.search,
          color: Color(0xFF536B61),
        ),

        suffixIcon: filter.searchText.isEmpty

            ? null

            : IconButton(

                icon: const Icon(
                  Icons.clear,
                  color: Color(0xFF536B61),
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

        fillColor: const Color(0xEEFFFFFF),

        contentPadding:
            const EdgeInsets.symmetric(

          horizontal: 14,

          vertical: 15,
        ),

        border: OutlineInputBorder(

          borderRadius: BorderRadius.circular(14),

          borderSide: const BorderSide(
            color: Color(0xFFBDDBD1),
          ),
        ),

        enabledBorder: OutlineInputBorder(

          borderRadius: BorderRadius.circular(14),

          borderSide: const BorderSide(
            color: Color(0xFFBDDBD1),
          ),
        ),

        focusedBorder: OutlineInputBorder(

          borderRadius: BorderRadius.circular(14),

          borderSide: const BorderSide(
            color: Color(0xFF3E8877),
            width: 1.6,
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