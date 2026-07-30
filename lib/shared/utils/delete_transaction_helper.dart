import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers/connectivity_provider.dart';
import '../../core/services/logger_service.dart';
import '../../features/sync/presentation/providers/sync_provider.dart';
import '../../features/transactions/presentation/providers/transaction_repository_provider.dart';
import '../../shared/models/transaction_model.dart';
import 'provider_refresh_helper.dart';

Future<void> deleteTransaction({

  required BuildContext context,

  required WidgetRef ref,

  required TransactionModel transaction,
}) async {

  final confirmed = await showDialog<bool>(

    context: context,

    builder: (context) {

      return AlertDialog(

        title: const Text(
          'Delete Transaction',
        ),

        content: const Text(
          'Are you sure you want to delete this transaction?',
        ),

        actions: [

          TextButton(

            onPressed: () {

              Navigator.pop(
                context,
                false,
              );
            },

            child: const Text(
              'Cancel',
            ),
          ),

          FilledButton(

            onPressed: () {

              Navigator.pop(
                context,
                true,
              );
            },

            child: const Text(
              'Delete',
            ),
          ),
        ],
      );
    },
  );

  if (confirmed != true) {
    return;
  }

  try {

    final repository = await ref.read(
      transactionRepositoryProvider.future,
    );

    await repository.deleteTransaction(
      transaction,
    );

    await ProviderRefreshHelper
        .refreshAllFinancialData(
      ref,
    );

    final connectivity =
        ref.read(
      connectivityProvider,
    );

    connectivity.whenData(
      (result) async {

        final connected = result.any(
          (e) =>
              e !=
              ConnectivityResult.none,
        );

        if (!connected) {
          return;
        }

        final syncService =
            await ref.read(
          syncServiceProvider.future,
        );

        await syncService.syncAll();
      },
    );

    if (context.mounted) {

      ScaffoldMessenger.of(context)
          .showSnackBar(

        const SnackBar(

          content: Text(
            'Transaction deleted successfully.',
          ),
        ),
      );
    }

  } catch (e, stackTrace) {

    LoggerService.exception(

      'Delete Transaction',

      e,

      stackTrace,
    );

    if (context.mounted) {

      ScaffoldMessenger.of(context)
          .showSnackBar(

        const SnackBar(

          content: Text(
            'Unable to delete transaction.',
          ),
        ),
      );
    }
  }
}