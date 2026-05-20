import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../transactions/presentation/screens/add_transaction_screen.dart';
import '../../../transactions/presentation/screens/transaction_list_screen.dart';
import '../../../reports/presentation/screens/reports_screen.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../auth/presentation/screens/login_screen.dart';
import '../../../sync/presentation/providers/sync_provider.dart';
import '../../../settings/presentation/screens/settings_screen.dart';
import '../../../dashboard/presentation/providers/transaction_filter_provider.dart';
import '../../../dashboard/presentation/providers/transactions_provider.dart';


class TransactionListContainerScreen extends ConsumerStatefulWidget {
  const TransactionListContainerScreen({super.key});

  @override
  ConsumerState<TransactionListContainerScreen> createState() =>
      _TransactionListContainerScreenState();
}

class _TransactionListContainerScreenState
    extends ConsumerState<TransactionListContainerScreen> {
  bool syncing = false;

  Future<void> syncData() async {
    setState(() {
      syncing = true;
    });

    try {
      final syncService = await ref.read(
        syncServiceProvider.future,
      );

      await syncService.syncAll();

      ref.invalidate(
        transactionsStreamProvider,
      );


      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Sync completed',
          ),
        ),
      );
    } catch (e) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Unable to sync. Please try again.',
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          syncing = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
       

    return Scaffold(

      appBar: AppBar(
        centerTitle: false,

        title: const Text(
          'Finance Tracker',
        ),

        actions: [

          IconButton(
            onPressed: () {

              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      const ReportsScreen(),
                ),
              );
            },
            icon: const Icon(
              Icons.bar_chart,
            ),
          ),

          IconButton(

            onPressed:
                syncing
                    ? null
                    : syncData,

            icon: syncing
                ? const SizedBox(

                    height: 20,
                    width: 20,

                    child:
                        CircularProgressIndicator(
                      strokeWidth: 2,
                    ),
                  )
                : const Icon(
                    Icons.sync,
                  ),
          ),

          IconButton(
            onPressed: () {

              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      const SettingsScreen(),
                ),
              );
            },
            icon: const Icon(
              Icons.settings,
            ),
          ),

          IconButton(
            onPressed: () async {

              final auth =
                  ref.read(
                authServiceProvider,
              );

              await auth.signOut();

              if (context.mounted) {

                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        const LoginScreen(),
                  ),
                  (route) => false,
                );
              }
            },
            icon: const Icon(
              Icons.logout,
            ),
          ),


        ],
        
      ),
      body: Column(
        children: [

          const SizedBox(height: 16),

          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
            ),

            child: Row(

              mainAxisAlignment:
                  MainAxisAlignment.spaceBetween,

              children: [

                const Text(
                  'Recent Transactions',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                _LimitDropdown(),
              ],
            ),
          ),

          const SizedBox(height: 8),

          const Padding(
            padding: EdgeInsets.symmetric(
              horizontal: 12,
            ),
            child: _TypeFilterChips(),
          ),

          const SizedBox(height: 8),

          const Expanded(
            child: TransactionListScreen(),
          ),
        ],
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) =>
                  const AddTransactionScreen(),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _LimitDropdown extends ConsumerWidget {

  @override
  Widget build(
    BuildContext context,
    WidgetRef ref,
  ) {

    final filter =
        ref.watch(transactionFilterProvider);

    return DropdownButton<TransactionLimit>(

      value: filter.limit,

      underline: const SizedBox.shrink(),

      isDense: true,

      icon: const Icon(
        Icons.arrow_drop_down,
      ),

      onChanged: (value) {

        if (value == null) {
          return;
        }

        ref
            .read(
              transactionFilterProvider.notifier,
            )
            .setLimit(value);
      },

      items: TransactionLimit.values
          .map(
            (TransactionLimit l) =>
                DropdownMenuItem<TransactionLimit>(
              value: l,
              child: Text(l.label),
            ),
          )
          .toList(),
    );
  }
}

class _TypeFilterChips extends ConsumerWidget {

  const _TypeFilterChips();

  @override
  Widget build(
    BuildContext context,
    WidgetRef ref,
  ) {

    final filter =
        ref.watch(transactionFilterProvider);

    return Row(

      children: TransactionTypeFilter.values.map(
        (TransactionTypeFilter t) {

          final selected = filter.type == t;

          return Padding(

            padding: const EdgeInsets.symmetric(
              horizontal: 4,
            ),

            child: ChoiceChip(

              label: Text(t.label),

              selected: selected,

              onSelected: (_) {

                ref
                    .read(
                      transactionFilterProvider.notifier,
                    )
                    .setType(t);
              },
            ),
          );
        },
      ).toList(),
    );
  }
}
