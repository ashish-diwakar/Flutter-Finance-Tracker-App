import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/config/currency_config.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../shared/models/account_model.dart';
import '../../../../shared/models/transaction_model.dart';
import '../../../../shared/providers/currency_provider.dart';
import '../../../../shared/utils/provider_refresh_helper.dart';
import '../../../accounts/presentation/providers/accounts_provider.dart';
import '../../../categories/presentation/providers/categories_provider.dart';
import '../../domain/services/repayment_service.dart';
import '../providers/transaction_repository_provider.dart';
import '../providers/transactions_provider.dart';

class TransactionDetailsScreen extends ConsumerWidget {
  final TransactionModel transaction;

  const TransactionDetailsScreen({
    super.key,
    required this.transaction,
  });

  @override
  Widget build(
    BuildContext context,
    WidgetRef ref,
  ) {
    final theme = Theme.of(context);
    final currency = ref.watch(currencyProvider);

    final typePresentation =
        _presentationForType(transaction.type);

    final categoriesAsync =
        ref.watch(allCategoriesProvider);

    final categoryName =
        categoriesAsync.when(
      data: (categories) {
        final categoryId =
            transaction.categoryId;

        if (categoryId == null ||
            categoryId.isEmpty) {
          return null;
        }

        final matching = categories.where(
          (category) =>
              category.uuid == categoryId,
        );

        if (matching.isEmpty) {
          return 'Unknown Category';
        }

        return matching.first.name;
      },
      loading: () =>
          transaction.categoryId == null
              ? null
              : 'Loading...',
      error: (_, _) =>
          transaction.categoryId == null
              ? null
              : 'Unknown Category',
    );

    final accountsAsync =
        ref.watch(accountsProvider);

    final accountName =
        accountsAsync.when(
      data: (accounts) =>
          _accountName(
        accounts,
        transaction.accountId,
      ),
      loading: () => 'Loading...',
      error: (_, _) => 'Unknown Account',
    );

    final toAccountName =
        accountsAsync.when(
      data: (accounts) {
        final toAccountId =
            transaction.toAccountId;

        if (toAccountId == null ||
            toAccountId.isEmpty) {
          return null;
        }

        return _accountName(
          accounts,
          toAccountId,
        );
      },
      loading: () =>
          transaction.toAccountId == null
              ? null
              : 'Loading...',
      error: (_, _) =>
          transaction.toAccountId == null
              ? null
              : 'Unknown Account',
    );

    final isBorrowOrLend =
        transaction.type == 'borrowed' ||
        transaction.type == 'lent';

    final transactionsAsync =
        ref.watch(
      transactionsStreamProvider,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Transaction Details',
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Card(
              elevation: 1,
              child: Padding(
                padding:
                    const EdgeInsets.all(24),
                child: Column(
                  children: [
                    Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        color: typePresentation.color
                            .withValues(
                          alpha: 0.12,
                        ),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        typePresentation.icon,
                        size: 32,
                        color:
                            typePresentation.color,
                      ),
                    ),
                    const SizedBox(
                      height: 16,
                    ),
                    Text(
                      '${typePresentation.prefix}'
                      '${CurrencyFormatter.format(
                        amount:
                            transaction.amount,
                        currency: currency,
                      )}',
                      textAlign: TextAlign.center,
                      style: theme
                          .textTheme
                          .headlineMedium
                          ?.copyWith(
                        fontWeight:
                            FontWeight.bold,
                        color:
                            typePresentation.color,
                      ),
                    ),
                    const SizedBox(
                      height: 8,
                    ),
                    Container(
                      padding:
                          const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: typePresentation.color
                            .withValues(
                          alpha: 0.10,
                        ),
                        borderRadius:
                            BorderRadius.circular(
                          20,
                        ),
                      ),
                      child: Text(
                        typePresentation.label,
                        style: TextStyle(
                          color:
                              typePresentation.color,
                          fontWeight:
                              FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(
              height: 16,
            ),

            Card(
              child: Padding(
                padding:
                    const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Transaction Information',
                      style: theme
                          .textTheme
                          .titleLarge
                          ?.copyWith(
                        fontWeight:
                            FontWeight.bold,
                      ),
                    ),
                    const SizedBox(
                      height: 16,
                    ),

                    if (categoryName !=
                        null) ...[
                      _DetailRow(
                        icon:
                            Icons.category_outlined,
                        label: 'Category',
                        value: categoryName,
                      ),
                      const Divider(
                        height: 24,
                      ),
                    ],

                    _DetailRow(
                      icon: Icons
                          .account_balance_wallet_outlined,
                      label:
                          transaction.type ==
                                  'transfer'
                              ? 'From Account'
                              : 'Account',
                      value: accountName,
                    ),

                    if (transaction.type ==
                            'transfer' &&
                        toAccountName !=
                            null) ...[
                      const Divider(
                        height: 24,
                      ),
                      _DetailRow(
                        icon: Icons
                            .account_balance_wallet,
                        label: 'To Account',
                        value: toAccountName,
                      ),
                    ],

                    if ((transaction
                                .counterpartyName ??
                            '')
                        .trim()
                        .isNotEmpty) ...[
                      const Divider(
                        height: 24,
                      ),
                      _DetailRow(
                        icon:
                            Icons.person_outline,
                        label:
                            transaction.type ==
                                    'borrowed'
                                ? 'Borrowed From'
                                : transaction.type ==
                                        'lent'
                                    ? 'Lent To'
                                    : 'Counterparty',
                        value: transaction
                            .counterpartyName!
                            .trim(),
                      ),
                    ],

                    if (transaction.dueDate !=
                        null) ...[
                      const Divider(
                        height: 24,
                      ),
                      _DetailRow(
                        icon: Icons
                            .event_available_outlined,
                        label: 'Due Date',
                        value: _formatDate(
                          transaction.dueDate!
                              .toLocal(),
                        ),
                      ),
                    ],

                    if ((transaction
                                .relatedTransactionId ??
                            '')
                        .isNotEmpty) ...[
                      const Divider(
                        height: 24,
                      ),
                      _DetailRow(
                        icon:
                            Icons.link_outlined,
                        label:
                            'Related Transaction',
                        value: transaction
                            .relatedTransactionId!,
                      ),
                    ],

                    const Divider(
                      height: 24,
                    ),
                    _DetailRow(
                      icon: Icons
                          .calendar_today_outlined,
                      label: 'Date',
                      value: _formatDate(
                        transaction
                            .transactionDate
                            .toLocal(),
                      ),
                    ),
                    const Divider(
                      height: 24,
                    ),
                    _DetailRow(
                      icon:
                          Icons.access_time_outlined,
                      label: 'Time',
                      value: _formatTime(
                        transaction
                            .transactionDate
                            .toLocal(),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            if (isBorrowOrLend) ...[
              const SizedBox(
                height: 16,
              ),
              transactionsAsync.when(
                data: (transactions) {
                  final outstanding =
                      RepaymentService
                          .getOutstandingAmount(
                    originalTransaction:
                        transaction,
                    transactions:
                        transactions,
                  );

                  final repaid =
                      transaction.amount -
                          outstanding;

                  return Card(
                    child: Padding(
                      padding:
                          const EdgeInsets.all(
                        20,
                      ),
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment
                                .start,
                        children: [
                          Text(
                            transaction.type ==
                                    'borrowed'
                                ? 'Loan Repayment'
                                : 'Money Recovery',
                            style: theme
                                .textTheme
                                .titleLarge
                                ?.copyWith(
                              fontWeight:
                                  FontWeight.bold,
                            ),
                          ),
                          const SizedBox(
                            height: 16,
                          ),
                          _DetailRow(
                            icon: Icons
                                .payments_outlined,
                            label:
                                'Original Amount',
                            value:
                                CurrencyFormatter
                                    .format(
                              amount:
                                  transaction.amount,
                              currency: currency,
                            ),
                          ),
                          const Divider(
                            height: 24,
                          ),
                          _DetailRow(
                            icon: Icons
                                .check_circle_outline,
                            label:
                                transaction.type ==
                                        'borrowed'
                                    ? 'Repaid'
                                    : 'Received Back',
                            value:
                                CurrencyFormatter
                                    .format(
                              amount: repaid,
                              currency: currency,
                            ),
                          ),
                          const Divider(
                            height: 24,
                          ),
                          _DetailRow(
                            icon: Icons
                                .account_balance_outlined,
                            label: 'Outstanding',
                            value:
                                CurrencyFormatter
                                    .format(
                              amount:
                                  outstanding,
                              currency: currency,
                            ),
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          SizedBox(
                            width: double.infinity,
                            child:
                                ElevatedButton.icon(
                              onPressed:
                                  outstanding <= 0
                                      ? null
                                      : () async {
                                          await _recordRepayment(
                                            context:
                                                context,
                                            ref: ref,
                                            originalTransaction:
                                                transaction,
                                            outstandingAmount:
                                                outstanding,
                                            currency:
                                                currency,
                                          );
                                        },
                              icon: Icon(
                                outstanding <= 0
                                    ? Icons
                                        .check_circle
                                    : Icons
                                        .add_card_outlined,
                              ),
                              label: Text(
                                outstanding <= 0
                                    ? 'Fully Repaid'
                                    : 'Record Repayment',
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
                loading: () =>
                    const Card(
                  child: Padding(
                    padding:
                        EdgeInsets.all(24),
                    child: Center(
                      child:
                          CircularProgressIndicator(),
                    ),
                  ),
                ),
                error: (_, _) =>
                    const Card(
                  child: Padding(
                    padding:
                        EdgeInsets.all(20),
                    child: Text(
                      'Unable to load repayment information.',
                    ),
                  ),
                ),
              ),
            ],

            if (transaction.notes != null &&
                transaction.notes!
                    .trim()
                    .isNotEmpty) ...[
              const SizedBox(
                height: 16,
              ),
              Card(
                child: Padding(
                  padding:
                      const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Notes',
                        style: theme
                            .textTheme
                            .titleLarge
                            ?.copyWith(
                          fontWeight:
                              FontWeight.bold,
                        ),
                      ),
                      const SizedBox(
                        height: 12,
                      ),
                      Container(
                        width: double.infinity,
                        padding:
                            const EdgeInsets.all(
                          16,
                        ),
                        decoration:
                            BoxDecoration(
                          color: theme
                              .colorScheme
                              .surfaceContainerHighest,
                          borderRadius:
                              BorderRadius.circular(
                            12,
                          ),
                        ),
                        child: Text(
                          transaction.notes!
                              .trim(),
                          style: theme
                              .textTheme
                              .bodyLarge,
                          softWrap: true,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],

            const SizedBox(
              height: 16,
            ),

            Card(
              child: Padding(
                padding:
                    const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Record Information',
                      style: theme
                          .textTheme
                          .titleLarge
                          ?.copyWith(
                        fontWeight:
                            FontWeight.bold,
                      ),
                    ),
                    const SizedBox(
                      height: 16,
                    ),
                    _DetailRow(
                      icon: Icons.update_outlined,
                      label: 'Last Updated',
                      value: _formatDateTime(
                        transaction.updatedAt,
                      ),
                    ),
                    const Divider(
                      height: 24,
                    ),
                    _DetailRow(
                      icon: Icons
                          .cloud_done_outlined,
                      label: 'Sync Status',
                      value:
                          transaction.isSynced
                              ? 'Synced'
                              : 'Local',
                    ),
                    if (transaction
                        .isDeleted) ...[
                      const Divider(
                        height: 24,
                      ),
                      const _DetailRow(
                        icon:
                            Icons.delete_outline,
                        label: 'Status',
                        value: 'Deleted',
                      ),
                    ],
                  ],
                ),
              ),
            ),

            const SizedBox(
              height: 16,
            ),

            Card(
              child: Padding(
                padding:
                    const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Transaction ID',
                      style: theme
                          .textTheme
                          .titleMedium
                          ?.copyWith(
                        fontWeight:
                            FontWeight.bold,
                      ),
                    ),
                    const SizedBox(
                      height: 8,
                    ),
                    SelectableText(
                      transaction.uuid,
                      style: theme
                          .textTheme
                          .bodySmall
                          ?.copyWith(
                        color: theme
                            .colorScheme
                            .onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(
              height: 48,
            ),
          ],
        ),
      ),
    );
  }

  static Future<void> _recordRepayment({
    required BuildContext context,
    required WidgetRef ref,
    required TransactionModel originalTransaction,
    required int outstandingAmount,
    required CurrencyConfig currency,
  }) async {
    final accounts =
        await ref.read(
      accountsProvider.future,
    );

    if (!context.mounted) {
      return;
    }

    if (accounts.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Please create an account before recording a repayment.',
          ),
        ),
      );
      return;
    }

    final amountController =
        TextEditingController();

    String? selectedAccountId =
        accounts.any(
      (account) =>
          account.uuid ==
          originalTransaction.accountId,
    )
            ? originalTransaction.accountId
            : accounts.first.uuid;

    DateTime selectedDate = DateTime.now();

    String? amountError;
    String? accountError;
    String? saveError;
    bool saving = false;

    try {
      final saved =
          await showDialog<bool>(
        context: context,
        barrierDismissible: !saving,
        builder: (dialogContext) {
          return StatefulBuilder(
            builder: (
              dialogContext,
              setDialogState,
            ) {
              return AlertDialog(
                title: Text(
                  originalTransaction.type ==
                          'borrowed'
                      ? 'Record Repayment Paid'
                      : 'Record Repayment Received',
                ),
                content:
                    SingleChildScrollView(
                  child: Column(
                    mainAxisSize:
                        MainAxisSize.min,
                    children: [
                      Text(
                        'Outstanding: '
                        '${CurrencyFormatter.format(
                          amount:
                              outstandingAmount,
                          currency: currency,
                        )}',
                      ),
                      const SizedBox(
                        height: 16,
                      ),
                      TextField(
                        controller:
                            amountController,
                        enabled: !saving,
                        keyboardType:
                            const TextInputType
                                .numberWithOptions(
                          decimal: true,
                        ),
                        decoration:
                            InputDecoration(
                          labelText:
                              'Repayment Amount',
                          border:
                              const OutlineInputBorder(),
                          errorText:
                              amountError,
                        ),
                        onChanged: (_) {
                          if (amountError !=
                              null) {
                            setDialogState(
                              () {
                                amountError =
                                    null;
                              },
                            );
                          }
                        },
                      ),
                      const SizedBox(
                        height: 16,
                      ),
                      InputDecorator(
                        decoration:
                            InputDecoration(
                          labelText:
                              originalTransaction
                                          .type ==
                                      'borrowed'
                                  ? 'Paid From Account'
                                  : 'Received Into Account',
                          border:
                              const OutlineInputBorder(),
                          errorText:
                              accountError,
                        ),
                        child:
                            DropdownButtonHideUnderline(
                          child:
                              DropdownButton<
                                  String>(
                            value:
                                selectedAccountId,
                            isExpanded: true,
                            items: accounts
                                .map(
                                  (account) =>
                                      DropdownMenuItem<
                                          String>(
                                    value:
                                        account.uuid,
                                    child: Text(
                                      account.name,
                                    ),
                                  ),
                                )
                                .toList(),
                            onChanged: saving
                                ? null
                                : (value) {
                                    setDialogState(
                                      () {
                                        selectedAccountId =
                                            value;
                                        accountError =
                                            null;
                                      },
                                    );
                                  },
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 16,
                      ),
                      InkWell(
                        onTap: saving
                            ? null
                            : () async {
                                final picked =
                                    await showDatePicker(
                                  context:
                                      dialogContext,
                                  initialDate:
                                      selectedDate,
                                  firstDate:
                                      DateTime(
                                    2020,
                                  ),
                                  lastDate:
                                      DateTime
                                          .now(),
                                );

                                if (picked !=
                                    null) {
                                  setDialogState(
                                    () {
                                      selectedDate =
                                          picked;
                                    },
                                  );
                                }
                              },
                        child:
                            InputDecorator(
                          decoration:
                              const InputDecoration(
                            labelText:
                                'Repayment Date',
                            border:
                                OutlineInputBorder(),
                            suffixIcon: Icon(
                              Icons
                                  .calendar_today,
                            ),
                          ),
                          child: Text(
                            _formatDate(
                              selectedDate,
                            ),
                          ),
                        ),
                      ),
                      if (saveError !=
                          null) ...[
                        const SizedBox(
                          height: 12,
                        ),
                        Text(
                          saveError!,
                          style: TextStyle(
                            color: Theme.of(
                              dialogContext,
                            )
                                .colorScheme
                                .error,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: saving
                        ? null
                        : () {
                            Navigator.pop(
                              dialogContext,
                              false,
                            );
                          },
                    child:
                        const Text('Cancel'),
                  ),
                  ElevatedButton(
                    onPressed: saving
                        ? null
                        : () async {
                            final parsedAmount =
                                double.tryParse(
                              amountController
                                  .text
                                  .trim(),
                            );

                            final amount =
                                parsedAmount ==
                                        null
                                    ? null
                                    : (parsedAmount *
                                            100)
                                        .toInt();

                            setDialogState(
                              () {
                                amountError =
                                    amount ==
                                                null ||
                                            amount <=
                                                0
                                        ? 'Enter a valid amount'
                                        : amount >
                                                outstandingAmount
                                            ? 'Amount cannot exceed outstanding balance'
                                            : null;

                                accountError =
                                    selectedAccountId ==
                                            null
                                        ? 'Please select an account'
                                        : null;

                                saveError =
                                    null;
                              },
                            );

                            if (amountError !=
                                    null ||
                                accountError !=
                                    null ||
                                amount == null) {
                              return;
                            }

                            setDialogState(
                              () {
                                saving = true;
                              },
                            );

                            try {
                              final repository =
                                  await ref.read(
                                transactionRepositoryProvider
                                    .future,
                              );

                              final now =
                                  DateTime.now();

                              final repaymentDate =
                                  DateTime(
                                selectedDate.year,
                                selectedDate
                                    .month,
                                selectedDate.day,
                                now.hour,
                                now.minute,
                                now.second,
                              ).toUtc();

                              final repayment =
                                  TransactionModel()
                                    ..uuid =
                                        const Uuid()
                                            .v4()
                                    ..amount =
                                        amount
                                    ..type =
                                        RepaymentService
                                            .repaymentTypeFor(
                                      originalTransaction,
                                    )
                                    ..transactionDate =
                                        repaymentDate
                                    ..categoryId =
                                        null
                                    ..accountId =
                                        selectedAccountId!
                                    ..toAccountId =
                                        null
                                    ..counterpartyName =
                                        originalTransaction
                                            .counterpartyName
                                    ..relatedTransactionId =
                                        originalTransaction
                                            .uuid
                                    ..dueDate =
                                        null
                                    ..notes =
                                        null
                                    ..updatedAt =
                                        DateTime
                                            .now()
                                            .toUtc()
                                    ..isSynced =
                                        false;

                              await repository
                                  .addTransaction(
                                repayment,
                              );

                              await ProviderRefreshHelper
                                  .refreshAllFinancialData(
                                ref,
                              );

                              ref.invalidate(
                                transactionsStreamProvider,
                              );

                              if (!dialogContext
                                  .mounted) {
                                return;
                              }

                              Navigator.pop(
                                dialogContext,
                                true,
                              );
                            } catch (_) {
                              if (!dialogContext
                                  .mounted) {
                                return;
                              }

                              setDialogState(
                                () {
                                  saveError =
                                      'Unable to save repayment. Please try again.';
                                  saving =
                                      false;
                                },
                              );
                            }
                          },
                    child: saving
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child:
                                CircularProgressIndicator(
                              strokeWidth: 2,
                            ),
                          )
                        : const Text(
                            'Save Repayment',
                          ),
                  ),
                ],
              );
            },
          );
        },
      );

      if (saved == true &&
          context.mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(
          const SnackBar(
            content: Text(
              'Repayment recorded',
            ),
          ),
        );
      }
    } finally {
      amountController.dispose();
    }
  }

  static String _accountName(
    List<AccountModel> accounts,
    String accountId,
  ) {
    final matching = accounts.where(
      (account) =>
          account.uuid == accountId,
    );

    if (matching.isEmpty) {
      return 'Unknown Account';
    }

    return matching.first.name;
  }

  static _TransactionTypePresentation
      _presentationForType(
    String type,
  ) {
    switch (type) {
      case 'income':
        return const _TransactionTypePresentation(
          label: 'Income',
          prefix: '+',
          color: Colors.green,
          icon: Icons.arrow_downward_rounded,
        );

      case 'expense':
        return const _TransactionTypePresentation(
          label: 'Expense',
          prefix: '-',
          color: Colors.red,
          icon: Icons.arrow_upward_rounded,
        );

      case 'transfer':
        return const _TransactionTypePresentation(
          label: 'Transfer',
          prefix: '',
          color: Colors.blue,
          icon: Icons.swap_horiz_rounded,
        );

      case 'borrowed':
        return const _TransactionTypePresentation(
          label: 'Borrowed',
          prefix: '+',
          color: Colors.green,
          icon: Icons
              .call_received_rounded,
        );

      case 'lent':
        return const _TransactionTypePresentation(
          label: 'Lent',
          prefix: '-',
          color: Colors.orange,
          icon: Icons.call_made_rounded,
        );

      case 'repaymentPaid':
        return const _TransactionTypePresentation(
          label: 'Repayment Paid',
          prefix: '-',
          color: Colors.red,
          icon: Icons
              .outbound_outlined,
        );

      case 'repaymentReceived':
        return const _TransactionTypePresentation(
          label: 'Repayment Received',
          prefix: '+',
          color: Colors.green,
          icon: Icons
              .move_to_inbox_outlined,
        );

      default:
        return const _TransactionTypePresentation(
          label: 'Transaction',
          prefix: '',
          color: Colors.blueGrey,
          icon: Icons
              .receipt_long_outlined,
        );
    }
  }

  static String _formatDate(
    DateTime date,
  ) {
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
  }

  static String _formatTime(
    DateTime date,
  ) {
    final hour = date.hour == 0
        ? 12
        : date.hour > 12
            ? date.hour - 12
            : date.hour;

    final minute = date.minute
        .toString()
        .padLeft(
          2,
          '0',
        );

    final period =
        date.hour >= 12 ? 'PM' : 'AM';

    return '$hour:$minute $period';
  }

  static String _formatDateTime(
    DateTime? date,
  ) {
    if (date == null) {
      return 'N/A';
    }

    final localDate = date.toLocal();

    return '${_formatDate(localDate)} '
        '${_formatTime(localDate)}';
  }
}

class _TransactionTypePresentation {
  final String label;
  final String prefix;
  final Color color;
  final IconData icon;

  const _TransactionTypePresentation({
    required this.label,
    required this.prefix,
    required this.color,
    required this.icon,
  });
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    final theme =
        Theme.of(context);

    return Row(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        Container(
          width: 42,
          height: 42,
          decoration:
              BoxDecoration(
            color: theme
                .colorScheme
                .primary
                .withValues(
              alpha: 0.10,
            ),
            borderRadius:
                BorderRadius.circular(
              12,
            ),
          ),
          child: Icon(
            icon,
            size: 22,
            color: theme
                .colorScheme
                .primary,
          ),
        ),
        const SizedBox(
          width: 14,
        ),
        Expanded(
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: theme
                    .textTheme
                    .bodySmall
                    ?.copyWith(
                  color: theme
                      .colorScheme
                      .onSurfaceVariant,
                ),
              ),
              const SizedBox(
                height: 3,
              ),
              Text(
                value,
                style: theme
                    .textTheme
                    .bodyLarge
                    ?.copyWith(
                  fontWeight:
                      FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
