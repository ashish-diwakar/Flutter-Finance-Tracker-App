import 'package:finance_tracker/core/services/logger_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/widgets/aurora_app_bar.dart';
import '../../../../shared/utils/provider_refresh_helper.dart';
import '../providers/backup_repository_provider.dart';

class BackupScreen extends ConsumerWidget {
  const BackupScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: const AuroraAppBar(title: Text('Backup & Restore')),
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
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () async {
                      final repository = await ref.read(
                        backupRepositoryProvider.future,
                      );

                      await repository.shareBackup();

                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Backup exported')),
                        );
                      }
                    },

                    child: const Text('Export Backup'),
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    // onPressed: () async {

                    //   final repository =
                    //       await ref.read(
                    //     backupRepositoryProvider
                    //         .future,
                    //   );

                    //   await repository
                    //       .importBackup();

                    //   if (context.mounted) {

                    //     ScaffoldMessenger.of(
                    //       context,
                    //     ).showSnackBar(
                    //       const SnackBar(
                    //         content: Text(
                    //           'Backup restored',
                    //         ),
                    //       ),
                    //     );
                    //   }
                    // },
                    onPressed: () async {
                      try {
                        final repository = await ref.read(
                          backupRepositoryProvider.future,
                        );

                        await repository.importBackup();

                        await ProviderRefreshHelper.refreshAllFinancialData(
                          ref,
                        );

                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Backup restored successfully'),
                            ),
                          );
                        }
                      } catch (e, stack) {
                        LoggerService.error('Import Backup Error: $e');
                        LoggerService.error('Import Backup Error: $stack');

                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Import failed: $e')),
                          );
                        }
                      }
                    },

                    child: const Text('Import Backup'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
