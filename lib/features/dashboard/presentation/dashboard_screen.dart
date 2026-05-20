import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/utils/currency_formatter.dart';
import '../../../core/widgets/summary_card.dart';
import '../../transactions/presentation/screens/add_transaction_screen.dart';
import '../../transactions/presentation/screens/transaction_list_screen.dart';
import 'providers/balance_provider.dart';
import 'providers/expense_provider.dart';
import 'providers/income_provider.dart';
import '../../reports/presentation/screens/reports_screen.dart';
import '../../backup/presentation/screens/backup_screen.dart';
import '../../auth/presentation/providers/auth_provider.dart';
import '../../auth/presentation/screens/login_screen.dart';
import '../../settings/presentation/screens/settings_screen.dart';


class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {

    final income =
        ref.watch(totalIncomeProvider).value ?? 0;

    final expense =
        ref.watch(totalExpenseProvider).value ?? 0;

    final balance =
        ref.watch(totalBalanceProvider);

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

          // IconButton(
          //   onPressed: () {

          //     Navigator.push(
          //       context,
          //       MaterialPageRoute(
          //         builder: (_) =>
          //             const BackupScreen(),
          //       ),
          //     );
          //   },
          //   icon: const Icon(
          //     Icons.backup,
          //   ),
          // ),

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
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Recent Transactions',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
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
