import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/widgets/aurora_app_bar.dart';
import '../../../../core/services/app_settings_service.dart';

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
import '../../../about/presentation/screens/open_source_licenses_screen.dart';
import '../../../support/presentation/screens/contact_support_screen.dart';
import '../../../privacy/presentation/screens/privacy_policy_screen.dart';
import '../../../security/presentation/providers/app_lock_enabled_provider.dart';
import '../../../security/presentation/providers/app_lock_provider.dart';
import '../../../security/services/app_lock_service.dart';

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
  final Widget? child;

  const _SettingsSection({
    required this.title,
    this.options = const [],
    this.child,
  });

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
          if (options.isNotEmpty)
            Material(
              type: MaterialType.transparency,
              borderRadius: BorderRadius.circular(12),
              clipBehavior: Clip.antiAlias,
              child: Column(
                children: [
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
            ),
          ?child,
        ],
      ),
    );
  }
}

class _AppLockStatus extends ConsumerStatefulWidget {
  const _AppLockStatus({required this.enabled});

  final bool? enabled;

  @override
  ConsumerState<_AppLockStatus> createState() => _AppLockStatusState();
}

class _AppLockStatusState extends ConsumerState<_AppLockStatus> {
  bool _busy = false;
  String? _message;
  AppLockService? _activeAuth;

  @override
  void dispose() {
    final activeAuth = _activeAuth;
    if (activeAuth != null) {
      unawaited(activeAuth.cancelAuthentication());
    }
    super.dispose();
  }

  Future<void> _change(bool requested) async {
    if (_busy ||
        ref.read(appLockVerificationRequiredProvider) ||
        widget.enabled == null ||
        requested == widget.enabled) {
      return;
    }
    setState(() {
      _busy = true;
      _message = null;
    });
    try {
      if (!requested) {
        final proceed = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Turn off App Lock?'),
            content: const Text(
              'Future fresh launches will open without device authentication. '
              'Anyone using your unlocked device can view Finance Tracker. '
              'The local database and exported JSON backups are not encrypted by App Lock.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Continue'),
              ),
            ],
          ),
        );
        if (!mounted || proceed != true) return;
      }
      final auth = ref.read(appLockServiceProvider);
      if (requested) {
        final supported = await auth.isDeviceSupported();
        if (!mounted) return;
        if (!supported) {
          setState(
            () => _message =
                'Device authentication is unavailable. App Lock was not changed.',
          );
          return;
        }
      }
      _activeAuth = auth;
      final authenticated = await auth.authenticate();
      _activeAuth = null;
      if (!authenticated) {
        if (mounted) {
          setState(
            () => _message =
                'Authentication was not completed. App Lock was not changed.',
          );
        }
        return;
      }
      if (!mounted) return;
      ref.read(appLockVerificationRequiredProvider.notifier).state = true;
      final result = await AppSettingsService.saveAppLockEnabled(requested);
      if (!mounted) return;
      if (result.observedEnabled == null) {
        setState(() {
          _message =
              'Could not verify the saved App Lock setting. Check its status before changing it again.';
        });
        return;
      }
      ref.invalidate(appLockEnabledProvider);
      final current = await ref.read(appLockEnabledProvider.future);
      if (!mounted) return;
      if (current != result.observedEnabled) {
        setState(() {
          _message =
              'Could not verify the saved App Lock setting. Check its status before changing it again.';
        });
        return;
      }
      ref.read(appLockVerificationRequiredProvider.notifier).state = false;
      setState(() {
        _message = result.confirmed && current == requested
            ? 'App Lock ${requested ? 'enabled' : 'disabled'}. The change takes effect on the next fresh launch.'
            : 'App Lock could not be changed. The current setting is ${current ? 'on' : 'off'}.';
      });
    } catch (_) {
      if (mounted) {
        setState(
          () => _message = 'App Lock could not be changed. Please try again.',
        );
      }
    } finally {
      _activeAuth = null;
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _checkStatus() async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      final observed = await AppSettingsService.reloadAppLockEnabled();
      if (!mounted) return;
      if (observed == null) {
        setState(
          () => _message =
              'Could not verify App Lock status. Try checking again.',
        );
        return;
      }
      ref.invalidate(appLockEnabledProvider);
      final current = await ref.read(appLockEnabledProvider.future);
      if (!mounted) return;
      if (current != observed) {
        setState(
          () => _message =
              'Could not verify App Lock status. Try checking again.',
        );
        return;
      }
      ref.read(appLockVerificationRequiredProvider.notifier).state = false;
      setState(() {
        _message = 'App Lock status checked.';
      });
    } catch (_) {
      if (mounted) {
        setState(
          () => _message =
              'Could not verify App Lock status. Try checking again.',
        );
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final unverified = ref.watch(appLockVerificationRequiredProvider);
    final enabled = unverified ? null : widget.enabled;
    return Padding(
      key: const Key('app-lock-status'),
      padding: const EdgeInsets.fromLTRB(4, 8, 4, 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: const Color(0xFFDDF0E5),
                  borderRadius: BorderRadius.circular(12),
                ),
                alignment: Alignment.center,
                child: Icon(
                  enabled == false
                      ? Icons.lock_open_outlined
                      : Icons.lock_outline,
                  color: AuroraAppBar.inkColor,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'App Lock',
                      style: TextStyle(
                        color: AuroraAppBar.inkColor,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      enabled == null
                          ? unverified
                                ? 'App Lock status is unverified.'
                                : 'Checking App Lock status…'
                          : enabled
                          ? 'A fresh launch requires device authentication to enter Finance Tracker.'
                          : 'A fresh launch does not require device authentication.',
                      style: const TextStyle(
                        color: Color(0xFF435F55),
                        fontSize: 14,
                        height: 1.35,
                      ),
                    ),
                    const SizedBox(height: 8),
                    DecoratedBox(
                      decoration: BoxDecoration(
                        color: const Color(0xFFDDF0E5),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        child: Text(
                          enabled == null
                              ? unverified
                                    ? 'Unverified'
                                    : 'Checking…'
                              : enabled
                              ? 'On'
                              : 'Off',
                          style: const TextStyle(
                            color: AuroraAppBar.inkColor,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 4),
              if (!unverified)
                Switch.adaptive(
                  key: const Key('app-lock-switch'),
                  value: enabled ?? true,
                  onChanged: _busy || enabled == null ? null : _change,
                ),
            ],
          ),
          const SizedBox(height: 12),
          const Text(
            'Changes take effect on the next fresh launch.',
            style: TextStyle(
              color: Color(0xFF435F55),
              fontSize: 14,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'When enabled, App Lock limits entry to the app. It does not encrypt the local database or exported JSON backups.',
            style: TextStyle(
              color: Color(0xFF435F55),
              fontSize: 14,
              height: 1.35,
            ),
          ),
          if (_busy)
            const Padding(
              padding: EdgeInsets.only(top: 8),
              child: LinearProgressIndicator(),
            ),
          if (_message != null)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                _message!,
                style: const TextStyle(color: AuroraAppBar.inkColor),
              ),
            ),
          if (unverified)
            TextButton(
              onPressed: _busy ? null : _checkStatus,
              child: const Text('Check status'),
            ),
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
      minVerticalPadding: 10,
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: const Color(0xFFDDF0E5),
          borderRadius: BorderRadius.circular(12),
        ),
        alignment: Alignment.center,
        child: Icon(option.icon, color: const Color(0xFF315F53), size: 22),
      ),
      title: Text(
        option.title,
        style: const TextStyle(
          color: Color(0xFF315F53),
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
      subtitle: Text(
        option.description,
        style: const TextStyle(
          color: Color(0xFF435F55),
          fontSize: 14,
          fontWeight: FontWeight.w400,
          height: 1.35,
        ),
      ),
      trailing: const Icon(
        Icons.chevron_right,
        color: Color(0xFF315F53),
        size: 20,
      ),
      onTap: option.onTap,
    );
  }
}

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lockEnabled = ref
        .watch(appLockEnabledProvider)
        .when(
          data: (enabled) => enabled,
          loading: () => null,
          error: (error, stackTrace) => true,
        );
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
              title: 'Security',
              child: _AppLockStatus(enabled: lockEnabled),
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
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const OpenSourceLicensesScreen(),
                      ),
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
