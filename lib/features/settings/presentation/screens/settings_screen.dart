import 'package:flutter/material.dart';

import '../../../accounts/presentation/screens/manage_accounts_screen.dart';
import '../../../backup/presentation/screens/backup_screen.dart';
import '../../../categories/presentation/screens/manage_categories_screen.dart';
import '../../../reports/presentation/screens/budget_alerts_screen.dart';

class SettingsScreen
    extends StatelessWidget {

  const SettingsScreen({
    super.key,
  });

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(
        title: const Text(
          'Settings',
        ),
      ),

      body: ListView(

        children: [

          // =====================================================
          // Manage Categories Screen Link
          // =====================================================
          ListTile(

            leading:
                const Icon(Icons.category),

            title:
                const Text(
              'Manage Categories',
            ),

            trailing:
                const Icon(Icons.chevron_right),

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

          // =====================================================
          // Manage Accounts Screen Link
          // =====================================================
          ListTile(

            leading:
                const Icon(Icons.account_balance_wallet),

            title:
                const Text(
              'Manage Accounts',
            ),

            trailing:
                const Icon(Icons.chevron_right),

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

          // =====================================================
          // Backup & Restore Screen Link
          // =====================================================

          ListTile(

            leading:
                const Icon(Icons.backup),

            title:
                const Text(
              'Backup & Restore',
            ),

            trailing:
                const Icon(Icons.chevron_right),

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


          // =====================================================
          // Budget Alerts Screen Link
          // =====================================================
          ListTile(

            leading: const Icon(
              Icons.warning_amber,
            ),

            title: const Text(
              'Budget Alerts',
            ),

            trailing: const Icon(
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

        ],
      ),
    );
  }
}