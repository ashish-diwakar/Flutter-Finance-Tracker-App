import 'package:finance_tracker/shared/utils/provider_refresh_helper.dart';

import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:uuid/uuid.dart';

import '../../../../shared/models/account_model.dart';

import '../providers/account_repository_provider.dart';

import '../../../../core/utils/currency_formatter.dart';

import '../../../../shared/providers/currency_provider.dart';

import '../providers/account_balances_provider.dart';

class ManageAccountsScreen extends ConsumerStatefulWidget {
  const ManageAccountsScreen({super.key});

  @override
  ConsumerState<ManageAccountsScreen> createState() =>
      _ManageAccountsScreenState();
}

class _ManageAccountsScreenState extends ConsumerState<ManageAccountsScreen> {
  List<AccountModel> accounts = [];

  bool loading = true;

  bool _deletingAccount = false;

  @override
  void initState() {
    super.initState();

    loadAccounts();
  }

  Future<void> loadAccounts() async {
    final repository = await ref.read(accountRepositoryProvider.future);

    final result = await repository.getAccounts();

    setState(() {
      accounts = result;

      loading = false;
    });
  }

  Future<void> confirmDeleteAccount(AccountModel account) async {
    if (_deletingAccount) {
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: const Color(0xFFF3FAF5),
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          constraints: const BoxConstraints(maxWidth: 440),
          insetPadding: const EdgeInsets.symmetric(
            horizontal: 18,
            vertical: 24,
          ),
          scrollable: true,
          titlePadding: const EdgeInsets.fromLTRB(20, 24, 20, 8),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 12,
          ),
          actionsPadding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          actionsOverflowButtonSpacing: 8,
          title: const Row(
            children: [
              DecoratedBox(
                decoration: BoxDecoration(
                  color: Color(0xFFFBE6E3),
                  borderRadius: BorderRadius.all(Radius.circular(12)),
                ),
                child: SizedBox(
                  width: 44,
                  height: 44,
                  child: Icon(Icons.delete_outline, color: Color(0xFFB54C44)),
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Delete Account?',
                  style: TextStyle(
                    color: Color(0xFF315F53),
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          content: SizedBox(
            width: 440,
            child: Text(
              'Account: ${account.name}\n'
              'Type: ${account.type}\n\n'
              'Deleting an account may affect financial records associated with it.',
              style: const TextStyle(color: Color(0xFF244C40), fontSize: 16),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(false);
              },
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFF315F53),
                minimumSize: const Size(88, 48),
                side: const BorderSide(color: Color(0xFFB5D9CA)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                textStyle: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              child: const Text('Cancel'),
            ),
            FilledButton.icon(
              onPressed: () {
                Navigator.of(dialogContext).pop(true);
              },
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFFB54C44),
                foregroundColor: Colors.white,
                minimumSize: const Size(104, 48),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                textStyle: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              icon: const Icon(Icons.delete_outline),
              label: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (confirmed != true || !mounted) {
      return;
    }

    _deletingAccount = true;
    try {
      final repository = await ref.read(accountRepositoryProvider.future);
      if (!mounted) {
        return;
      }

      try {
        await repository.deleteAccount(account);
        if (!mounted) {
          return;
        }

        await loadAccounts();
      } catch (e) {
        if (!mounted) {
          return;
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              e is StateError ? e.message : 'Unable to delete account',
            ),
          ),
        );
      }
    } finally {
      _deletingAccount = false;
    }
  }

  Future<void> showAccountDialog({AccountModel? account}) async {
    final nameController = TextEditingController(text: account?.name ?? '');

    final formKey = GlobalKey<FormState>();

    String type = account?.type ?? 'bank';

    final repository = await ref.read(accountRepositoryProvider.future);

    if (!mounted) {
      return;
    }

    await showDialog(
      context: context,

      builder: (_) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text(account == null ? 'Add Account' : 'Edit Account'),

              content: Form(
                key: formKey,

                child: Column(
                  mainAxisSize: MainAxisSize.min,

                  children: [
                    TextFormField(
                      controller: nameController,

                      decoration: const InputDecoration(
                        labelText: 'Account Name',

                        errorMaxLines: 2,
                      ),

                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Account name is required';
                        }

                        final trimmedName = value.trim();

                        if (trimmedName.length < 2) {
                          return 'Minimum 2 characters required';
                        }

                        final normalizedName = trimmedName.toLowerCase();

                        final isDuplicate = accounts.any((existing) {
                          return existing.uuid != account?.uuid &&
                              existing.type == type &&
                              existing.name.trim().toLowerCase() ==
                                  normalizedName;
                        });

                        if (isDuplicate) {
                          return 'Account name already exists\nfor this type';
                        }

                        return null;
                      },
                    ),

                    const SizedBox(height: 16),

                    DropdownButton<String>(
                      value: type,

                      isExpanded: true,

                      items: const [
                        DropdownMenuItem(value: 'bank', child: Text('Bank')),

                        DropdownMenuItem(value: 'cash', child: Text('Cash')),

                        DropdownMenuItem(
                          value: 'credit_card',

                          child: Text('Credit Card'),
                        ),
                      ],

                      onChanged: (value) {
                        setDialogState(() {
                          type = value!;
                        });
                      },
                    ),
                  ],
                ),
              ),

              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },

                  child: const Text('Cancel'),
                ),

                ElevatedButton(
                  onPressed: () async {
                    if (!formKey.currentState!.validate()) {
                      return;
                    }

                    if (account == null) {
                      final newAccount = AccountModel()
                        ..uuid = const Uuid().v4()
                        ..name = nameController.text.trim()
                        ..type = type
                        ..currentBalance = 0
                        ..isSynced = false
                        ..updatedAt = DateTime.now().toUtc();

                      await repository.addAccount(newAccount);

                      ProviderRefreshHelper.refreshAccountsData(ref);
                    } else {
                      account.name = nameController.text.trim();

                      account.type = type;

                      await repository.updateAccount(account);

                      ProviderRefreshHelper.refreshAccountsData(ref);
                    }

                    if (context.mounted) {
                      Navigator.pop(context);
                    }

                    if (mounted) {
                      await loadAccounts();
                    }
                  },

                  child: const Text('Save'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final balancesAsync = ref.watch(accountBalancesProvider);

    final balances = balancesAsync.value ?? <String, int>{};

    final currency = ref.watch(currencyProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Manage Accounts')),

      floatingActionButton: FloatingActionButton(
        heroTag: 'manageaccounts_fab',

        onPressed: () {
          showAccountDialog();
        },

        child: const Icon(Icons.add),
      ),

      body: loading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: accounts.length,

              itemBuilder: (context, index) {
                final account = accounts[index];

                final calculatedBalance =
                    balances[account.uuid] ?? account.currentBalance;

                return ListTile(
                  title: Text(account.name),

                  subtitle: Text(
                    '${account.type} • '
                    '${CurrencyFormatter.format(amount: calculatedBalance, currency: currency)}',
                  ),

                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,

                    children: [
                      if (!account.isDefault)
                        IconButton(
                          onPressed: () {
                            showAccountDialog(account: account);
                          },

                          icon: const Icon(Icons.edit),
                        ),

                      if (!account.isDefault)
                        IconButton(
                          tooltip: 'Delete Account',
                          onPressed: () {
                            confirmDeleteAccount(account);
                          },

                          icon: const Icon(Icons.delete),
                        ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}
