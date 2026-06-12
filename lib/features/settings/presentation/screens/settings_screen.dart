import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';


import '../../../accounts/presentation/screens/manage_accounts_screen.dart';
import '../../../backup/presentation/screens/backup_screen.dart';
import '../../../categories/presentation/screens/manage_categories_screen.dart';
import '../../../export/presentation/screens/export_screen.dart';
import '../../../recurring/presentation/screens/recurring_transactions_screen.dart';
import '../../../reports/presentation/screens/budget_alerts_screen.dart';
import 'currency_settings_screen.dart';
import '../../../../shared/providers/currency_provider.dart';
import '../../../investments/presentation/screens/portfolio_screen.dart';
import '../../../goals/presentation/screens/manage_goals_screen.dart';

class SettingsScreen
    extends ConsumerWidget {

  const SettingsScreen({
    super.key,
  });

  @override
  Widget build(
    BuildContext context,
    WidgetRef ref,
  ) {

    return Scaffold(

      appBar: AppBar(

        title: const Text(
          'Settings',
        ),
      ),

      body: ListView(

        padding:
            const EdgeInsets.only(
          bottom: 40,
        ),

        children: [

          // =====================================================
          // GENERAL SECTION
          // =====================================================

          const Padding(

            padding: EdgeInsets.fromLTRB(
              16,
              20,
              16,
              8,
            ),

            child: Text(

              'General',

              style: TextStyle(

                fontSize: 16,

                fontWeight:
                    FontWeight.bold,
              ),
            ),
          ),

          
          // =====================================================
          // MANAGE CURRENCY
          // =====================================================
          Card(

            margin:
                const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 4,
            ),

            child: ListTile(

              leading: const Icon(
                Icons.currency_exchange,
              ),

              title: const Text(
                'Default Currency',
              ),

              subtitle: Text(

                '${ref.watch(currencyProvider).flag} '
                '${ref.watch(currencyProvider).code}',
              ),

              trailing: const Icon(
                Icons.chevron_right,
              ),

              onTap: () {

                Navigator.push(

                  context,

                  MaterialPageRoute(

                    builder: (_) =>
                        const CurrencySettingsScreen(),
                  ),
                );
              },
            ),
          ),

          // =====================================================
          // MANAGE CATEGORIES
          // =====================================================
          Card(

            margin:
                const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 4,
            ),

            child: ListTile(

              leading:
                  const Icon(
                Icons.category,
              ),

              title:
                  const Text(
                'Manage Categories',
              ),

              subtitle:
                  const Text(
                'Add, edit and organize categories',
              ),

              trailing:
                  const Icon(
                Icons.chevron_right,
              ),

              onTap: () {

                Navigator.push(

                  context,

                  MaterialPageRoute(

                    builder: (_) =>
                        const ManageCategoriesScreen(),
                  ),
                );
              },
            ),
          ),

          // =====================================================
          // MANAGE ACCOUNTS
          // =====================================================

          Card(

            margin:
                const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 4,
            ),

            child: ListTile(

              leading:
                  const Icon(
                Icons.account_balance_wallet,
              ),

              title:
                  const Text(
                'Manage Accounts',
              ),

              subtitle:
                  const Text(
                'Manage wallets and bank accounts',
              ),

              trailing:
                  const Icon(
                Icons.chevron_right,
              ),

              onTap: () {

                Navigator.push(

                  context,

                  MaterialPageRoute(

                    builder: (_) =>
                        const ManageAccountsScreen(),
                  ),
                );
              },
            ),
          ),

          // =====================================================
          // AUTOMATION SECTION
          // =====================================================

          const Padding(

            padding: EdgeInsets.fromLTRB(
              16,
              24,
              16,
              8,
            ),

            child: Text(

              'Automation',

              style: TextStyle(

                fontSize: 16,

                fontWeight:
                    FontWeight.bold,
              ),
            ),
          ),

          // =====================================================
          // RECURRING TRANSACTIONS
          // =====================================================

          Card(

            margin:
                const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 4,
            ),

            child: ListTile(

              leading:
                  const Icon(
                Icons.repeat,
              ),

              title:
                  const Text(
                'Recurring Transactions',
              ),

              subtitle:
                  const Text(
                'Manage automated transactions',
              ),

              trailing:
                  const Icon(
                Icons.chevron_right,
              ),

              onTap: () {

                Navigator.push(

                  context,

                  MaterialPageRoute(

                    builder: (_) =>
                        const RecurringTransactionsScreen(),
                  ),
                );
              },
            ),
          ),

          // =====================================================
          // WEALTH MANAGEMENT SECTION
          // =====================================================

          const Padding(

            padding: EdgeInsets.fromLTRB(
              16,
              24,
              16,
              8,
            ),

            child: Text(

              'Wealth Management',

              style: TextStyle(

                fontSize: 16,

                fontWeight:
                    FontWeight.bold,
              ),
            ),
          ),

          // =====================================================
          // FINANCIAL GOALS
          // =====================================================

          Card(

            margin:
                const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 4,
            ),

            child: ListTile(

              leading:
                  const Icon(
                Icons.flag,
              ),

              title:
                  const Text(
                'Financial Goals',
              ),

              subtitle:
                  const Text(
                'Track savings goals and progress',
              ),

              trailing:
                  const Icon(
                Icons.chevron_right,
              ),

              onTap: () {

                Navigator.push(

                  context,

                  MaterialPageRoute(

                    builder: (_) =>
                        const ManageGoalsScreen(),
                  ),
                );
              },
            ),
          ),

          // =====================================================
          // INVESTMENTS
          // =====================================================

          Card(

            margin:
                const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 4,
            ),

            child: ListTile(

              leading:
                  const Icon(
                Icons.trending_up,
              ),

              title:
                  const Text(
                'Investments',
              ),

              subtitle:
                  const Text(
                'Track portfolio performance and returns',
              ),

              trailing:
                  const Icon(
                Icons.chevron_right,
              ),

              onTap: () {

                Navigator.push(

                  context,

                  MaterialPageRoute(

                    builder: (_) =>
                        const PortfolioScreen(),
                  ),
                );
              },
            ),
          ),

          // =====================================================
          // ALERTS & REPORTS SECTION
          // =====================================================

          const Padding(

            padding: EdgeInsets.fromLTRB(
              16,
              24,
              16,
              8,
            ),

            child: Text(

              'Alerts & Reports',

              style: TextStyle(

                fontSize: 16,

                fontWeight:
                    FontWeight.bold,
              ),
            ),
          ),

          // =====================================================
          // BUDGET ALERTS
          // =====================================================

          Card(

            margin:
                const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 4,
            ),

            child: ListTile(

              leading:
                  const Icon(
                Icons.warning_amber,
              ),

              title:
                  const Text(
                'Budget Alerts',
              ),

              subtitle:
                  const Text(
                'View overspending and warnings',
              ),

              trailing:
                  const Icon(
                Icons.chevron_right,
              ),

              onTap: () {

                Navigator.push(

                  context,

                  MaterialPageRoute(

                    builder: (_) =>
                        const BudgetAlertsScreen(),
                  ),
                );
              },
            ),
          ),

          // =====================================================
          // EXPORT & BACKUP SECTION
          // =====================================================

          const Padding(

            padding: EdgeInsets.fromLTRB(
              16,
              24,
              16,
              8,
            ),

            child: Text(

              'Data Management',

              style: TextStyle(

                fontSize: 16,

                fontWeight:
                    FontWeight.bold,
              ),
            ),
          ),

          // =====================================================
          // EXPORT SCREEN
          // =====================================================

          Card(

            margin:
                const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 4,
            ),

            child: ListTile(

              leading:
                  const Icon(
                Icons.download,
              ),

              title:
                  const Text(
                'Export Data',
              ),

              subtitle:
                  const Text(
                'Export transactions as CSV or PDF',
              ),

              trailing:
                  const Icon(
                Icons.chevron_right,
              ),

              onTap: () {

                Navigator.push(

                  context,

                  MaterialPageRoute(

                    builder: (_) =>
                        const ExportScreen(),
                  ),
                );
              },
            ),
          ),

          // =====================================================
          // BACKUP & RESTORE
          // =====================================================

          Card(

            margin:
                const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 4,
            ),

            child: ListTile(

              leading:
                  const Icon(
                Icons.backup,
              ),

              title:
                  const Text(
                'Backup & Restore',
              ),

              subtitle:
                  const Text(
                'Import or export JSON backups',
              ),

              trailing:
                  const Icon(
                Icons.chevron_right,
              ),

              onTap: () {

                Navigator.push(

                  context,

                  MaterialPageRoute(

                    builder: (_) =>
                        const BackupScreen(),
                  ),
                );
              },
            ),
          ),

          const SizedBox(
            height: 24,
          ),
        ],
      ),
    );
  }
}