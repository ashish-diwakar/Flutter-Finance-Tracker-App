import 'package:finance_tracker/features/transactions/presentation/providers/transaction_filter_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/models/account_model.dart';
import '../../../accounts/presentation/providers/accounts_provider.dart';

class AccountFilterDropdown extends ConsumerWidget {
  const AccountFilterDropdown({
    super.key,
  });

  static const String _allAccountsValue =
      '__all_accounts__';

  @override
  Widget build(
    BuildContext context,
    WidgetRef ref,
  ) {
    final accountsAsync =
        ref.watch(
      accountsProvider,
    );

    final filter =
        ref.watch(
      transactionFilterProvider,
    );

    return accountsAsync.when(
      loading: () =>
          const Center(
        child:
            CircularProgressIndicator(),
      ),
      error: (_, _) =>
          const Text(
        'Unable to load accounts',
      ),
      data: (accounts) {
        final selectedValue =
            filter.accountId ??
                _allAccountsValue;

        return DropdownButtonFormField<String>(
          isExpanded: true,
          key: ValueKey(
            selectedValue,
          ),
          style: const TextStyle(
            color: Color(0xFF244C40),
            fontSize: 16,
          ),
          initialValue:
              selectedValue,
          decoration: InputDecoration(
            labelText: 'Account',
            labelStyle: const TextStyle(
              color: Color(0xFF536B61),
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
            floatingLabelStyle: const TextStyle(
              color: Color(0xFF536B61),
              fontSize: 18.67,
              fontWeight: FontWeight.w500,
            ),
            filled: true,
            fillColor: const Color(0xEEFFFFFF),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 15,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: Color(0xFFBDDBD1)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(
                color: Color(0xFF3E8877),
                width: 1.6,
              ),
            ),
          ),
          items: [
            const DropdownMenuItem<String>(
              value:
                  _allAccountsValue,
              child: Text(
                'All Accounts',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            ...accounts.map(
              (AccountModel account) {
                return DropdownMenuItem<String>(
                  value:
                      account.uuid,
                  child: Text(
                    account.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                );
              },
            ),
          ],
          onChanged: (value) {
            if (value == null) {
              return;
            }

            ref
                .read(
                  transactionFilterProvider.notifier,
                )
                .setAccountId(
                  value ==
                          _allAccountsValue
                      ? null
                      : value,
                );
          },
        );
      },
    );
  }
}
