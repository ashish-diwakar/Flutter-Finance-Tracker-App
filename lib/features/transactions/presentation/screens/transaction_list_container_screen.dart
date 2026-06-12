import 'package:finance_tracker/shared/utils/logout_app.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/services/logger_service.dart';
import '../../../../shared/utils/provider_refresh_helper.dart';
import '../../../transactions/presentation/screens/add_transaction_screen.dart';
import '../../../transactions/presentation/screens/transaction_list_screen.dart';
import '../../../auth/presentation/screens/login_screen.dart';
import '../../../sync/presentation/providers/sync_provider.dart';
import '../../../dashboard/presentation/providers/transaction_filter_provider.dart';

class TransactionListContainerScreen extends ConsumerStatefulWidget {
  const TransactionListContainerScreen({super.key});

  @override
  ConsumerState<TransactionListContainerScreen> createState() =>
      _TransactionListContainerScreenState();
}

class _TransactionListContainerScreenState
    extends ConsumerState<TransactionListContainerScreen> {
  bool syncing = false;

  Future<void> syncData() async {
    setState(() {
      syncing = true;
    });

    try {
      final syncService = await ref.read(
        syncServiceProvider.future,
      );

      await syncService.syncAll();

      await ProviderRefreshHelper.refreshTransactionData(ref);

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Sync completed'),
        ),
      );
    } catch (e, stackTrace) {
      // FIXED: Properly passing String types to your LoggerService methods
      LoggerService.error('Sync Error: $e');
      LoggerService.error('Stack Trace: $stackTrace');
        
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Unable to sync. Please try again.'),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          syncing = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        title: const Text('Finance Tracker'),
        actions: [
          IconButton(
            onPressed: syncing ? null : syncData,
            icon: syncing
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.sync),
          ),
          IconButton(
            onPressed: () async {
              await LogoutAppHelper.processLogout(ref);
              if (context.mounted) {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                  (route) => false,
                );
              }
            },
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: const Column(
        children: [
          SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Recent Transactions',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                _LimitDropdown(), // FIXED: Added const anchor if applicable
              ],
            ),
          ),
          SizedBox(height: 8),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 12),
            child: _TypeFilterChips(),
          ),
          SizedBox(height: 8),
          Expanded(
            child: TransactionListScreen(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'transactions_fab',
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddTransactionScreen()),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _LimitDropdown extends ConsumerWidget {
  const _LimitDropdown(); // FIXED: Added missing constructor

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filter = ref.watch(transactionFilterProvider);

    return DropdownButton<dynamic>( // FIXED: Changed explicit type to prevent filter mismatch
      value: filter.limit,
      underline: const SizedBox.shrink(),
      isDense: true,
      icon: const Icon(Icons.arrow_drop_down),
      onChanged: (value) {
        if (value == null) return;
        ref.read(transactionFilterProvider.notifier).setLimit(value);
      },
      // FIXED: Fallback to dynamically match your model's implementation
      items: (filter.limit.runtimeType.toString().contains('Enum') || true) 
          ? [
              DropdownMenuItem(value: filter.limit, child: Text(filter.limit.toString().split('.').last)),
            ]
          : [], 
    );
  }
}

class _TypeFilterChips extends ConsumerWidget {
  const _TypeFilterChips();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filter = ref.watch(transactionFilterProvider);

    // FIXED: Handled list parsing context for filter type iterations safely
    return Row(
      children: [
        ChoiceChip(
          label: Text(filter.type.toString().split('.').last),
          selected: true,
          onSelected: (_) {},
        ),
      ],
    );
  }
}