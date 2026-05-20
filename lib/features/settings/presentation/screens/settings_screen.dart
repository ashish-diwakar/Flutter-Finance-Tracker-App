import 'package:flutter/material.dart';

import '../../../accounts/presentation/screens/manage_accounts_screen.dart';
import '../../../backup/presentation/screens/backup_screen.dart';
import '../../../categories/presentation/screens/manage_categories_screen.dart';

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
        ],
      ),
    );
  }
}