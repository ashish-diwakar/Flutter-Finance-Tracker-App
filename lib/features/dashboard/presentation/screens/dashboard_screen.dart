import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/widgets/summary_card.dart';
import '../../../transactions/presentation/screens/add_transaction_screen.dart';
import '../../../transactions/presentation/screens/transaction_list_screen.dart';
import '../providers/balance_provider.dart';
import '../providers/expense_provider.dart';
import '../providers/income_provider.dart';
//import '../../../reports/presentation/screens/reports_screen.dart';
//import '../../../backup/presentation/screens/backup_screen.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../auth/presentation/screens/login_screen.dart';
import '../../../sync/presentation/providers/sync_provider.dart';
//import '../../../settings/presentation/screens/settings_screen.dart';
//import '../providers/transaction_filter_provider.dart';
import '../providers/transactions_provider.dart';


class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() =>
      _DashboardScreenState();
}

class _DashboardScreenState
    extends ConsumerState<DashboardScreen> {
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

      ref.invalidate(
        totalIncomeProvider,
      );

      ref.invalidate(
        totalExpenseProvider,
      );

      ref.invalidate(
        totalBalanceProvider,
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

    final income =
        ref.watch(totalIncomeProvider).value ?? 0;

    final expense =
        ref.watch(totalExpenseProvider).value ?? 0;

    final balance =
        ref.watch(totalBalanceProvider);
    
    final appName = dotenv.env['APP_NAME'] ?? 'Finance Tracker';

    return Scaffold(

      appBar: AppBar(
        centerTitle: false,

        title: Text(
          appName,
        ),

        actions: [

          // IconButton(
          //   onPressed: () {

          //     Navigator.push(
          //       context,
          //       MaterialPageRoute(
          //         builder: (_) =>
          //             const ReportsScreen(),
          //       ),
          //     );
          //   },
          //   icon: const Icon(
          //     Icons.bar_chart,
          //   ),
          // ),

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

          // IconButton(
          //   onPressed: () {

          //     Navigator.push(
          //       context,
          //       MaterialPageRoute(
          //         builder: (_) =>
          //             const SettingsScreen(),
          //       ),
          //     );
          //   },
          //   icon: const Icon(
          //     Icons.settings,
          //   ),
          // ),

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

          Padding(
            padding: const EdgeInsets.all(12),

            child: Row(
              children: [

                SummaryCard(
                  title: 'Income',
                  amount: CurrencyFormatter.format(income),
                  icon: Icons.trending_up,
                ),

                const SizedBox(width: 8),

                SummaryCard(
                  title: 'Expense',
                  amount: CurrencyFormatter.format(expense),
                  icon: Icons.trending_down,
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 12,
            ),

            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(16),

                child: Column(
                  children: [

                    const Text(
                      'Total Balance',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 12),

                    Text(
                      CurrencyFormatter.format(balance),
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(height: 16),

          const Padding(
            padding: EdgeInsets.symmetric(
              horizontal: 16,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Recent Transactions',
                  style: TextStyle( // Removed redundant 'const' here
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          // const SizedBox(height: 8),

          // const Padding(
          //   padding: EdgeInsets.symmetric(
          //     horizontal: 12,
          //   ),
          //   child: _TypeFilterChips(),
          // ),

          const SizedBox(height: 8),

          const Expanded(
            child: TransactionListScreen(defaultLimit: 3,),
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

// class _LimitDropdown extends ConsumerWidget {

//   @override
//   Widget build(
//     BuildContext context,
//     WidgetRef ref,
//   ) {

//     final filter =
//         ref.watch(transactionFilterProvider);

//     return DropdownButton<TransactionLimit>(

//       value: filter.limit,

//       underline: const SizedBox.shrink(),

//       isDense: true,

//       icon: const Icon(
//         Icons.arrow_drop_down,
//       ),

//       onChanged: (value) {

//         if (value == null) {
//           return;
//         }

//         ref
//             .read(
//               transactionFilterProvider.notifier,
//             )
//             .setLimit(value);
//       },

//       items: TransactionLimit.values
//           .map(
//             (TransactionLimit l) =>
//                 DropdownMenuItem<TransactionLimit>(
//               value: l,
//               child: Text(l.label),
//             ),
//           )
//           .toList(),
//     );
//   }
// }

// class _TypeFilterChips extends ConsumerWidget {

//   const _TypeFilterChips();

//   @override
//   Widget build(
//     BuildContext context,
//     WidgetRef ref,
//   ) {

//     final filter =
//         ref.watch(transactionFilterProvider);

//     return Row(

//       children: TransactionTypeFilter.values.map(
//         (TransactionTypeFilter t) {

//           final selected = filter.type == t;

//           return Padding(

//             padding: const EdgeInsets.symmetric(
//               horizontal: 4,
//             ),

//             child: ChoiceChip(

//               label: Text(t.label),

//               selected: selected,

//               onSelected: (_) {

//                 ref
//                     .read(
//                       transactionFilterProvider.notifier,
//                     )
//                     .setType(t);
//               },
//             ),
//           );
//         },
//       ).toList(),
//     );
//   }
// }
