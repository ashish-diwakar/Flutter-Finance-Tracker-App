import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/models/account_model.dart';
import '../providers/account_repository_provider.dart';

class ManageAccountsScreen
    extends ConsumerStatefulWidget {

  const ManageAccountsScreen({
    super.key,
  });

  @override
  ConsumerState<ManageAccountsScreen>
      createState() =>
          _ManageAccountsScreenState();
}

class _ManageAccountsScreenState
    extends ConsumerState<
        ManageAccountsScreen> {

  List<AccountModel> accounts =
      [];

  bool loading = true;

  @override
  void initState() {

    super.initState();

    loadAccounts();
  }

  Future<void> loadAccounts()
      async {

    final repository =
        await ref.read(
      accountRepositoryProvider.future,
    );

    final result =
        await repository
            .getAccounts();

    setState(() {

      accounts = result;

      loading = false;
    });
  }

  Future<void> showAccountDialog({
    AccountModel? account,
  }) async {

    final nameController =
        TextEditingController(
      text: account?.name ?? '',
    );

    String type =
        account?.type ?? 'bank';

    final repository =
        await ref.read(
      accountRepositoryProvider.future,
    );

    if (!mounted) {
      return;
    }

    await showDialog(
      context: context,

      builder: (_) {

        return StatefulBuilder(

          builder: (
            context,
            setDialogState,
          ) {

            return AlertDialog(

              title: Text(
                account == null
                    ? 'Add Account'
                    : 'Edit Account',
              ),

              content: Column(
                mainAxisSize:
                    MainAxisSize.min,

                children: [

                  TextField(
                    controller:
                        nameController,

                    decoration:
                        const InputDecoration(
                      labelText:
                          'Account Name',
                    ),
                  ),

                  const SizedBox(
                    height: 16,
                  ),

                  DropdownButton<String>(

                    value: type,

                    isExpanded: true,

                    items: const [

                      DropdownMenuItem(
                        value: 'bank',
                        child: Text(
                          'Bank',
                        ),
                      ),

                      DropdownMenuItem(
                        value: 'cash',
                        child: Text(
                          'Cash',
                        ),
                      ),

                      DropdownMenuItem(
                        value:
                            'credit_card',
                        child: Text(
                          'Credit Card',
                        ),
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

              actions: [

                TextButton(
                  onPressed: () {

                    Navigator.pop(
                      context,
                    );
                  },
                  child: const Text(
                    'Cancel',
                  ),
                ),

                ElevatedButton(

                  onPressed: () async {

                    if (nameController
                        .text
                        .trim()
                        .isEmpty) {
                      return;
                    }

                    if (account ==
                        null) {

                      final newAccount =
                          AccountModel()

                            ..name =
                                nameController
                                    .text
                                    .trim()

                            ..type = type

                            ..currentBalance =
                                0

                            ..isSynced =
                                false

                            ..updatedAt =
                                DateTime.now();

                      await repository
                          .addAccount(
                        newAccount,
                      );

                    } else {

                      account.name =
                          nameController
                              .text
                              .trim();

                      account.type =
                          type;

                      await repository
                          .updateAccount(
                        account,
                      );
                    }

                    if (mounted) {

                      Navigator.pop(
                        context,
                      );

                      await loadAccounts();
                    }
                  },

                  child: const Text(
                    'Save',
                  ),
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

    return Scaffold(

      appBar: AppBar(
        title: const Text(
          'Manage Accounts',
        ),
      ),

      floatingActionButton:
          FloatingActionButton(

        onPressed: () {

          showAccountDialog();
        },

        child: const Icon(Icons.add),
      ),

      body: loading
          ? const Center(
              child:
                  CircularProgressIndicator(),
            )
          : ListView.builder(

              itemCount:
                  accounts.length,

              itemBuilder:
                  (context, index) {

                final account =
                    accounts[index];

                return ListTile(

                  title: Text(
                    account.name,
                  ),

                  subtitle: Text(
                    account.type,
                  ),

                  trailing: Row(
                    mainAxisSize:
                        MainAxisSize.min,

                    children: [

                      if (!account.isDefault)
                        IconButton(
                          onPressed: () {
                            showAccountDialog(
                              account:
                                  account,
                            );
                          },

                          icon: const Icon(
                            Icons.edit,
                          ),
                        ),


                      if (!account.isDefault)
                        IconButton(
                          onPressed:
                              () async {
                            final messenger =
                                ScaffoldMessenger.of(
                              context,
                            );

                            final repository =
                                await ref.read(
                              accountRepositoryProvider
                                  .future,
                            );

                            try {

                              await repository
                                  .deleteAccount(
                                account.id,
                              );

                              await loadAccounts();

                            } catch (e) {

                              messenger.showSnackBar(
                                SnackBar(
                                  content: Text(
                                    e is StateError
                                        ? e.message
                                        : 'Unable to delete account',
                                  ),
                                ),
                              );
                            }
                          },

                          icon: const Icon(
                            Icons.delete,
                          ),
                        ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}