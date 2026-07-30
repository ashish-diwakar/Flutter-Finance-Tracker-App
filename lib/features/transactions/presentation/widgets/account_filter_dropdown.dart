
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/models/account_model.dart';
import '../../../accounts/presentation/providers/accounts_provider.dart';
import '../../../dashboard/presentation/providers/transaction_filter_provider.dart';

class AccountFilterDropdown extends ConsumerWidget {

  const AccountFilterDropdown({
    super.key,
  });

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

      error: (_, __) =>
          const Text(
            'Unable to load accounts',
          ),

      data: (accounts) {

        return DropdownButtonFormField<String?>(

          value:
              filter.accountId,

          decoration:
              const InputDecoration(

            labelText:
                'Account',

            border:
                OutlineInputBorder(),
          ),

          items: [

            const DropdownMenuItem<String?>(

              value: null,

              child: Text(
                'All Accounts',
              ),
            ),

            ...accounts.map(

              (AccountModel account) {

                return DropdownMenuItem<String?>(

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

            ref
                .read(
                  transactionFilterProvider.notifier,
                )
                .setAccountId(
                  value,
                );
          },
        );
      },
    );
  }
}