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
          key: ValueKey(
            selectedValue,
          ),
          initialValue:
              selectedValue,
          decoration:
              const InputDecoration(
            labelText:
                'Account',
            border:
                OutlineInputBorder(),
          ),
          items: [
            const DropdownMenuItem<String>(
              value:
                  _allAccountsValue,
              child: Text(
                'All Accounts',
              ),
            ),
            ...accounts.map(
              (AccountModel account) {
                return DropdownMenuItem<String>(
                  value:
                      account.uuid,
                  child: Text(
                    account.name,
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
