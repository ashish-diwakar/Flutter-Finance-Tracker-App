import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/backup_repository_provider.dart';

class BackupScreen
    extends ConsumerWidget {

  const BackupScreen({
    super.key,
  });

  @override
  Widget build(
    BuildContext context,
    WidgetRef ref,
  ) {

    return Scaffold(

      appBar: AppBar(
        title: const Text(
          'Backup & Restore',
        ),
      ),

      body: Padding(
        padding:
            const EdgeInsets.all(16),

        child: Column(

          children: [

            SizedBox(
              width: double.infinity,

              child: ElevatedButton(

                onPressed: () async {

                  final repository =
                      await ref.read(
                    backupRepositoryProvider
                        .future,
                  );

                  await repository
                      .shareBackup();

                  if (context.mounted) {

                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Backup exported',
                        ),
                      ),
                    );
                  }
                },

                child: const Text(
                  'Export Backup',
                ),
              ),
            ),

            const SizedBox(height: 16),

            SizedBox(
              width: double.infinity,

              child: ElevatedButton(

                onPressed: () async {

                  final repository =
                      await ref.read(
                    backupRepositoryProvider
                        .future,
                  );

                  await repository
                      .importBackup();

                  if (context.mounted) {

                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Backup restored',
                        ),
                      ),
                    );
                  }
                },

                child: const Text(
                  'Import Backup',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}