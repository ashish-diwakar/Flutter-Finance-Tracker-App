import 'package:flutter/material.dart';
import 'package:isar/isar.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';

import '../../../../shared/providers/database_provider.dart';

import '../../../../shared/models/transaction_model.dart';

import '../../data/services/csv_export_service.dart';

class ExportScreen
    extends ConsumerStatefulWidget {

  const ExportScreen({
    super.key,
  });

  @override
  ConsumerState<ExportScreen>
      createState() =>
          _ExportScreenState();
}

class _ExportScreenState
    extends ConsumerState<
        ExportScreen> {

  bool exporting = false;

  Future<void>
      exportCsv()
  async {

    setState(() {
      exporting = true;
    });

    try {

      final isar =
          await ref.read(
        isarProvider.future,
      );

      final transactions =
          await isar
              .transactionModels
              .filter()
              .isDeletedEqualTo(
                false,
              )
              .findAll();

      final service =
          CsvExportService();

      final file =
          await service
              .exportTransactions(
        transactions,
      );

      await Share.shareXFiles([
        XFile(file.path),
      ]);

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(

        const SnackBar(

          content: Text(
            'CSV exported successfully',
          ),
        ),
      );

    } catch (_) {

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(

        const SnackBar(

          content: Text(
            'Unable to export CSV',
          ),
        ),
      );

    } finally {

      if (mounted) {

        setState(() {
          exporting = false;
        });
      }
    }
  }

  @override
  Widget build(
    BuildContext context,
  ) {

    return Scaffold(

      appBar: AppBar(

        title: const Text(
          'Export & Backup',
        ),
      ),

      body: ListView(

        padding:
            const EdgeInsets.all(
          16,
        ),

        children: [

          Card(

            child: ListTile(

              leading: const Icon(
                Icons.table_chart,
              ),

              title: const Text(
                'Export Transactions CSV',
              ),

              subtitle: const Text(
                'Export all transactions to CSV format',
              ),

              trailing:
                  exporting

                      ? const SizedBox(

                          height: 20,
                          width: 20,

                          child:
                              CircularProgressIndicator(
                            strokeWidth:
                                2,
                          ),
                        )

                      : const Icon(
                          Icons.chevron_right,
                        ),

              onTap:
                  exporting
                      ? null
                      : exportCsv,
            ),
          ),
        ],
      ),
    );
  }
}