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
                                                title: const Text(
                                                  'Delete Recurring Transaction',
                                                ),

                                                content: const Text(
                                                  'Are you sure you want to delete this recurring transaction?',
                                                ),

                                                actions: [
                                                  TextButton(
                                                    onPressed: () {
                                                      Navigator.of(
                                                        dialogContext,
                                                      ).pop(false);
                                                    },

                                                    child: const Text('Cancel'),
                                                  ),

                                                  ElevatedButton(
                                                    onPressed: () {
                                                      Navigator.of(
                                                        dialogContext,
                                                      ).pop(true);
                                                    },

                                                    child: const Text('Delete'),
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

                                      itemBuilder: (_) => [
                                        PopupMenuItem(
                                          value: 'toggle',

                                          child: Row(
                                            children: [
                                              Icon(
                                                item.isActive
                                                    ? Icons.pause
                                                    : Icons.play_arrow,
                                              ),

                                              const SizedBox(width: 12),

                                              Text(
                                                item.isActive
                                                    ? 'Pause'
                                                    : 'Activate',
                                              ),
                                            ],
                                          ),
                                        ),

                                        const PopupMenuItem(
                                          value: 'edit',

                                          child: Row(
                                            children: [
                                              Icon(Icons.edit),

                                              SizedBox(width: 12),

                                              Text('Edit'),
                                            ],
                                          ),
                                        ),

                                        const PopupMenuItem(
                                          value: 'delete',

                                          child: Row(
                                            children: [
                                              Icon(Icons.delete),

                                              SizedBox(width: 12),

                                              Text('Delete'),
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
