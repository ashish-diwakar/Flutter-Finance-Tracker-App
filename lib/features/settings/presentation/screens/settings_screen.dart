import 'package:finance_tracker/core/constants/app_constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/widgets/aurora_app_bar.dart';

import '../../../accounts/presentation/screens/manage_accounts_screen.dart';
import '../../../backup/presentation/screens/backup_screen.dart';
import '../../../categories/presentation/screens/manage_categories_screen.dart';
import '../../../export/presentation/screens/export_screen.dart';
import '../../../recurring/presentation/screens/recurring_transactions_screen.dart';
import '../../../reports/presentation/screens/budget_alerts_screen.dart';
import 'currency_settings_screen.dart';
import '../../../../shared/providers/currency_provider.dart';
import '../../../goals/presentation/screens/manage_goals_screen.dart';
import '../../../about/presentation/screens/about_screen.dart';
import '../../../support/presentation/screens/contact_support_screen.dart';
import '../../../privacy/presentation/screens/privacy_policy_screen.dart';

class _SettingsOption {
  final IconData icon;
  final String title;
  final String description;
  final VoidCallback onTap;

  const _SettingsOption({
    required this.icon,
    required this.title,
    required this.description,
    required this.onTap,
  });
}

class _SettingsSection extends StatelessWidget {
  final String title;
  final List<_SettingsOption> options;

  const _SettingsSection({required this.title, required this.options});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF0F8F2),
        border: Border.all(color: const Color(0xFFA8CFC0)),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 4,
                height: 22,
                decoration: BoxDecoration(
                  color: const Color(0xFF17664F),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    color: Color(0xFF315F53),
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          for (var index = 0; index < options.length; index++) ...[
            _SettingsOptionTile(option: options[index]),
            if (index < options.length - 1)
              const Divider(
                height: 1,
                thickness: 1,
                indent: 56,
                endIndent: 8,
                color: Color(0xFFD8E8DF),
              ),
          ],
        ],
      ),
    );
  }
}

class _SettingsOptionTile extends StatelessWidget {
  final _SettingsOption option;

  const _SettingsOptionTile({required this.option});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      minVerticalPadding: 8,
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: const Color(0xFFDDF0E5),
          borderRadius: BorderRadius.circular(12),
        ),
        alignment: Alignment.center,
        child: Icon(option.icon, color: const Color(0xFF315F53), size: 21),
      ),
      title: Text(
        option.title,
        style: const TextStyle(
          color: Color(0xFF244C40),
          fontWeight: FontWeight.w600,
        ),
      ),
      subtitle: Text(
        option.description,
        style: const TextStyle(color: Color(0xFF536B61)),
      ),
      trailing: const Icon(Icons.chevron_right, color: Color(0xFF315F53)),
      onTap: option.onTap,
    );
  }
}

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appName = AppConstants.appName;
    final appVersion = AppConstants.appVersion;

    return Scaffold(
      appBar: const AuroraAppBar(title: Text('Settings')),
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: [Color(0xFFB6D7CC), Color(0xFFDAEDE5), Color(0xFFF8FCFA)],
            stops: [0.0, 0.52, 1.0],
          ),
        ),
        child: ListView(
          padding: const EdgeInsets.fromLTRB(12, 16, 12, 40),
          children: [
            _SettingsSection(
              title: 'General',
              options: [
                _SettingsOption(
                  icon: Icons.currency_exchange,
                  title: 'Default Currency',
                  description:
                      '${ref.watch(currencyProvider).flag} '
                      '${ref.watch(currencyProvider).code}',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const CurrencySettingsScreen(),
                      ),
                    );
                  },
                ),
                _SettingsOption(
                  icon: Icons.category,
                  title: 'Manage Categories',
                  description: 'Add, edit and organize categories',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const ManageCategoriesScreen(),
                      ),
                    );
                  },
                ),
                _SettingsOption(
                  icon: Icons.account_balance_wallet,
                  title: 'Manage Accounts',
                  description: 'Manage wallets and bank accounts',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const ManageAccountsScreen(),
                      ),
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 20),
            _SettingsSection(
              title: 'Automation',
              options: [
                _SettingsOption(
                  icon: Icons.repeat,
                  title: 'Recurring Transactions',
                  description: 'Manage automated transactions',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const RecurringTransactionsScreen(),
                      ),
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 20),
            _SettingsSection(
              title: 'Wealth Management',
              options: [
                _SettingsOption(
                  icon: Icons.flag,
                  title: 'Financial Goals',
                  description: 'Track savings goals and progress',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const ManageGoalsScreen(),
                      ),
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 20),
            _SettingsSection(
              title: 'Alerts & Reports',
              options: [
                _SettingsOption(
                  icon: Icons.warning_amber,
                  title: 'Budget Alerts',
                  description: 'View overspending and warnings',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const BudgetAlertsScreen(),
                      ),
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 20),
            _SettingsSection(
              title: 'Data Management',
              options: [
                _SettingsOption(
                  icon: Icons.download,
                  title: 'Export Data',
                  description: 'Export transactions as CSV or PDF',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const ExportScreen()),
                    );
                  },
                ),
                _SettingsOption(
                  icon: Icons.backup,
                  title: 'Backup & Restore',
                  description: 'Import or export JSON backups',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const BackupScreen()),
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 20),
            _SettingsSection(
              title: 'Information & Support',
              options: [
                _SettingsOption(
                  icon: Icons.info_outline,
                  title: 'About Finance Tracker',
                  description: 'App information and company details',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const AboutScreen()),
                    );
                  },
                ),
                _SettingsOption(
                  icon: Icons.support_agent_outlined,
                  title: 'Contact & Support',
                  description: 'Get help or report a problem',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const ContactSupportScreen(),
                      ),
                    );
                  },
                ),
                _SettingsOption(
                  icon: Icons.privacy_tip_outlined,
                  title: 'Privacy Policy',
                  description: 'How your information is handled',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const PrivacyPolicyScreen(),
                      ),
                    );
                  },
                ),
                _SettingsOption(
                  icon: Icons.description_outlined,
                  title: 'Open Source Licenses',
                  description: 'Third-party software licenses',
                  onTap: () {
                    showLicensePage(
                      context: context,
                      applicationName: appName,
                      applicationVersion: appVersion,
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
