import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/widgets/aurora_app_bar.dart';
import '../../../../shared/utils/provider_refresh_helper.dart';
import '../providers/recurring_provider.dart';
import 'add_recurring_transaction_screen.dart';
import '../../../../shared/providers/currency_provider.dart';

class RecurringTransactionsScreen extends ConsumerWidget {
  const RecurringTransactionsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recurringAsync = ref.watch(recurringTransactionsProvider);

    final currency = ref.watch(currencyProvider);

    Widget deleteDetailRow(String label, String value) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 4,
            child: Text(
              label,
              style: const TextStyle(
                color: Color(0xFF607C70),
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            flex: 6,
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: const TextStyle(
                color: Color(0xFF244D40),
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      );
    }

    return Scaffold(
      appBar: const AuroraAppBar(title: Text('Recurring Transactions')),

      floatingActionButton: FloatingActionButton(
        heroTag: 'recurring_fab',
        tooltip: 'Add Recurring Transaction',
        backgroundColor: const Color(0xFF17664F),
        foregroundColor: Colors.white,
        elevation: 2,
        shape: const CircleBorder(),

        onPressed: () async {
          await Navigator.push(
            context,

            MaterialPageRoute(
              builder: (_) => const AddRecurringTransactionScreen(),
            ),
          );

          await ProviderRefreshHelper.refreshRecurringTransactionData(ref);
        },

        child: const Icon(Icons.add, size: 24),
      ),

      body: Stack(
        fit: StackFit.expand,
        children: [
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: [
                  Color(0xFFB6D7CC),
                  Color(0xFFDAEDE5),
                  Color(0xFFF8FCFA),
                ],
                stops: [0.0, 0.52, 1.0],
              ),
            ),
          ),
          recurringAsync.when(
            data: (items) {
              if (items.isEmpty) {
                return const Center(child: Text('No recurring transactions'));
              }

              return ListView.builder(
                padding: const EdgeInsets.only(bottom: 100),

                itemCount: items.length,

                itemBuilder: (context, index) {
                  final item = items[index];

                  return Card(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    color: const Color(0xFFF0F8F2),
                    surfaceTintColor: Colors.transparent,
                    elevation: 1,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                      side: const BorderSide(color: Color(0xFFB8D8CA)),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(14),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CircleAvatar(
                            child: Icon(
                              item.type == 'income'
                                  ? Icons.arrow_downward
                                  : Icons.arrow_upward,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        item.notes?.trim().isNotEmpty == true
                                            ? item.notes!
                                            : 'Recurring Transaction',
                                        style: const TextStyle(
                                          color: Color(0xFF244D40),
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                    PopupMenuButton<String>(
                                      onSelected: (value) async {
                                        // =====================================
                                        // TOGGLE ACTIVE
                                        // =====================================

                                        if (value == 'toggle') {
                                          final repository = await ref.read(
                                            recurringRepositoryProvider.future,
                                          );

                                          item.isActive = !item.isActive;

                                          item.updatedAt = DateTime.now()
                                              .toUtc();

                                          item.isSynced = false;

                                          await repository.updateRecurring(
                                            item,
                                          );

                                          await ProviderRefreshHelper.refreshRecurringTransactionData(
                                            ref,
                                          );
                                        }

                                        // =====================================
                                        // EDIT
                                        // =====================================

                                        if (value == 'edit') {
                                          if (!context.mounted) {
                                            return;
                                          }

                                          await Navigator.push(
                                            context,

                                            MaterialPageRoute(
                                              builder: (_) =>
                                                  AddRecurringTransactionScreen(
                                                    recurring: item,
                                                  ),
                                            ),
                                          );

                                          await ProviderRefreshHelper.refreshRecurringTransactionData(
                                            ref,
                                          );
                                        }

                                        // =====================================
                                        // DELETE
                                        // =====================================

                                        if (value == 'delete') {
                                          if (!context.mounted) {
                                            return;
                                          }

                                          final confirm = await showDialog<bool>(
                                            context: context,

                                            builder: (dialogContext) {
                                              return AlertDialog(
                                                backgroundColor: const Color(
                                                  0xFFF3FAF5,
                                                ),
                                                elevation: 4,
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(24),
                                                ),
                                                constraints:
                                                    const BoxConstraints(
                                                      maxWidth: 440,
                                                    ),
                                                insetPadding:
                                                    const EdgeInsets.symmetric(
                                                      horizontal: 18,
                                                      vertical: 24,
                                                    ),
                                                scrollable: true,
                                                titlePadding:
                                                    const EdgeInsets.fromLTRB(
                                                      20,
                                                      24,
                                                      20,
                                                      8,
                                                    ),
                                                contentPadding:
                                                    const EdgeInsets.symmetric(
                                                      horizontal: 20,
                                                      vertical: 12,
                                                    ),
                                                actionsPadding:
                                                    const EdgeInsets.fromLTRB(
                                                      16,
                                                      8,
                                                      16,
                                                      16,
                                                    ),
                                                actionsOverflowButtonSpacing: 8,
                                                title: const Text(
                                                  'Delete Recurring Transaction?',
                                                  style: TextStyle(
                                                    color: Color(0xFF315F53),
                                                    fontSize: 20,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),

                                                content: SizedBox(
                                                  width: 440,
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Container(
                                                        padding:
                                                            const EdgeInsets.all(
                                                              14,
                                                            ),
                                                        decoration: BoxDecoration(
                                                          color: const Color(
                                                            0xFFE5F1E9,
                                                          ),
                                                          borderRadius:
                                                              BorderRadius.circular(
                                                                14,
                                                              ),
                                                        ),
                                                        child: Column(
                                                          children: [
                                                            deleteDetailRow(
                                                              'Description',
                                                              item.notes
                                                                          ?.trim()
                                                                          .isNotEmpty ==
                                                                      true
                                                                  ? item.notes!
                                                                  : 'Recurring Transaction',
                                                            ),
                                                            const Divider(
                                                              height: 20,
                                                              color: Color(
                                                                0xFFC9DBD0,
                                                              ),
                                                            ),
                                                            deleteDetailRow(
                                                              'Amount',
                                                              CurrencyFormatter.format(
                                                                amount:
                                                                    item.amount,
                                                                currency:
                                                                    currency,
                                                              ),
                                                            ),
                                                            const Divider(
                                                              height: 20,
                                                              color: Color(
                                                                0xFFC9DBD0,
                                                              ),
                                                            ),
                                                            deleteDetailRow(
                                                              'Frequency',
                                                              '${item.frequency.toUpperCase()} • Every ${item.interval}',
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                      const SizedBox(
                                                        height: 14,
                                                      ),
                                                      const Text(
                                                        'Are you sure you want to delete this recurring transaction?',
                                                        style: TextStyle(
                                                          color: Color(
                                                            0xFF244C40,
                                                          ),
                                                          fontSize: 16,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),

                                                actions: [
                                                  TextButton(
                                                    onPressed: () {
                                                      Navigator.of(
                                                        dialogContext,
                                                      ).pop(false);
                                                    },
                                                    style: TextButton.styleFrom(
                                                      foregroundColor:
                                                          const Color(
                                                            0xFF315F53,
                                                          ),
                                                      minimumSize: const Size(
                                                        88,
                                                        48,
                                                      ),
                                                      side: const BorderSide(
                                                        color: Color(
                                                          0xFFB5D9CA,
                                                        ),
                                                      ),
                                                      shape: RoundedRectangleBorder(
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                              14,
                                                            ),
                                                      ),
                                                      textStyle:
                                                          const TextStyle(
                                                            fontSize: 16,
                                                            fontWeight:
                                                                FontWeight.w600,
                                                          ),
                                                    ),

                                                    child: const Text('Cancel'),
                                                  ),

                                                  FilledButton.icon(
                                                    onPressed: () {
                                                      Navigator.of(
                                                        dialogContext,
                                                      ).pop(true);
                                                    },
                                                    style: FilledButton.styleFrom(
                                                      backgroundColor:
                                                          const Color(
                                                            0xFFB54C44,
                                                          ),
                                                      foregroundColor:
                                                          Colors.white,
                                                      minimumSize: const Size(
                                                        104,
                                                        48,
                                                      ),
                                                      shape: RoundedRectangleBorder(
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                              14,
                                                            ),
                                                      ),
                                                      textStyle:
                                                          const TextStyle(
                                                            fontSize: 16,
                                                            fontWeight:
                                                                FontWeight.w600,
                                                          ),
                                                    ),
                                                    icon: const Icon(
                                                      Icons.delete_outline,
                                                    ),

                                                    label: const Text('Delete'),
                                                  ),
                                                ],
                                              );
                                            },
                                          );

                                          if (confirm != true) {
                                            return;
                                          }

                                          final repository = await ref.read(
                                            recurringRepositoryProvider.future,
                                          );

                                          await repository.deleteRecurring(
                                            item,
                                          );

                                          await ProviderRefreshHelper.refreshRecurringTransactionData(
                                            ref,
                                          );

                                          if (context.mounted) {
                                            ScaffoldMessenger.of(
                                              context,
                                            ).showSnackBar(
                                              const SnackBar(
                                                content: Text(
                                                  'Recurring transaction deleted',
                                                ),
                                              ),
                                            );
                                          }
                                        }
                                      },

                                      color: const Color(0xFFF3FAF5),
                                      elevation: 4,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(14),
                                      ),
                                      menuPadding: const EdgeInsets.symmetric(
                                        vertical: 4,
                                      ),
                                      itemBuilder: (_) => [
                                        PopupMenuItem(
                                          value: 'toggle',

                                          child: Row(
                                            children: [
                                              Icon(
                                                item.isActive
                                                    ? Icons.pause
                                                    : Icons.play_arrow,
                                                size: 20,
                                                color: const Color(0xFF315F53),
                                              ),

                                              const SizedBox(width: 12),

                                              Text(
                                                item.isActive
                                                    ? 'Pause'
                                                    : 'Activate',
                                                style: const TextStyle(
                                                  color: Color(0xFF315F53),
                                                  fontSize: 16,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),

                                        const PopupMenuItem(
                                          value: 'edit',

                                          child: Row(
                                            children: [
                                              Icon(
                                                Icons.edit,
                                                size: 20,
                                                color: Color(0xFF315F53),
                                              ),

                                              SizedBox(width: 12),

                                              Text(
                                                'Edit',
                                                style: TextStyle(
                                                  color: Color(0xFF315F53),
                                                  fontSize: 16,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),

                                        const PopupMenuItem(
                                          value: 'delete',

                                          child: Row(
                                            children: [
                                              Icon(
                                                Icons.delete,
                                                size: 20,
                                                color: Color(0xFFB54C44),
                                              ),

                                              SizedBox(width: 12),

                                              Text(
                                                'Delete',
                                                style: TextStyle(
                                                  color: Color(0xFFB54C44),
                                                  fontSize: 16,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  CurrencyFormatter.format(
                                    amount: item.amount,
                                    currency: currency,
                                  ),
                                  style: const TextStyle(
                                    color: Color(0xFF17664F),
                                    fontSize: 20,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  '${item.frequency.toUpperCase()} • Every ${item.interval}',
                                  style: const TextStyle(
                                    color: Color(0xFF536B61),
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const Padding(
                                  padding: EdgeInsets.symmetric(vertical: 10),
                                  child: Divider(
                                    height: 1,
                                    color: Color(0xFFD5E6DC),
                                  ),
                                ),
                                Wrap(
                                  crossAxisAlignment: WrapCrossAlignment.center,
                                  spacing: 10,
                                  runSpacing: 8,
                                  children: [
                                    Text(
                                      'Next: ${item.nextRunDate.toLocal().day}/${item.nextRunDate.toLocal().month}/${item.nextRunDate.toLocal().year}',
                                      style: const TextStyle(
                                        color: Color(0xFF536B61),
                                        fontSize: 14,
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 10,
                                        vertical: 5,
                                      ),
                                      decoration: BoxDecoration(
                                        color: item.isActive
                                            ? const Color(0xFFE0F3E7)
                                            : const Color(0xFFFFF1D6),
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Text(
                                        item.isActive ? 'Active' : 'Paused',
                                        style: TextStyle(
                                          color: item.isActive
                                              ? const Color(0xFF17664F)
                                              : const Color(0xFF815B20),
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },

            error: (_, _) => const Center(
              child: Text('Unable to load recurring transactions'),
            ),

            loading: () => const Center(child: CircularProgressIndicator()),
          ),
        ],
      ),
    );
  }
}
