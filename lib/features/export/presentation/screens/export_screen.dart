import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';
import 'package:isar/isar.dart';
import '../../../../shared/providers/database_provider.dart';
import '../../../../shared/models/transaction_model.dart';
import '../../data/services/csv_export_service.dart';
import '../../data/services/pdf_export_service.dart';

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

  final TextEditingController
      reportTitleController =
          TextEditingController(

    text:
        'Monthly Financial Report',
  );

  // =======================================================
  // EXPORT CSV
  // =======================================================

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

    } catch (e, s) {

        debugPrint(
          'CSV EXPORT ERROR:',
        );

        debugPrint(
          e.toString(),
        );

        debugPrint(
          s.toString(),
        );

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

  // =======================================================
  // EXPORT PDF
  // =======================================================

  Future<void>
      exportPdf()
  async {

    final reportTitle =
        reportTitleController
            .text
            .trim();

    if (reportTitle
        .isEmpty) {

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(

        const SnackBar(

          content: Text(
            'Please enter report title',
          ),
        ),
      );

      return;
    }

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

      double income = 0;

      double expense = 0;

      for (final t
          in transactions) {

        if (t.type ==
            'income') {

          income +=
              t.amount / 100;

        } else {

          expense +=
              t.amount / 100;
        }
      }

      final balance =
          income - expense;

      final service =
          PdfExportService();

      final file =
          await service
              .generateMonthlyReport(

        reportTitle:
            reportTitle,

        transactions:
            transactions,

        income: income,

        expense: expense,

        balance: balance,
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
            'PDF exported successfully',
          ),
        ),
      );

    } catch (e, s) {

        debugPrint(
          'PDF EXPORT ERROR:',
        );

        debugPrint(
          e.toString(),
        );

        debugPrint(
          s.toString(),
        );

        if (!mounted) {
          return;
        }

        ScaffoldMessenger.of(
          context,
        ).showSnackBar(

          SnackBar(

            content: Text(
              'PDF Export Error: $e',
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
  void dispose() {

    reportTitleController
        .dispose();

    super.dispose();
  }

  @override
  Widget build(
    BuildContext context,
  ) {

    return Scaffold(

      appBar: AppBar(

        title: const Text(
          'Export & Reports',
        ),
      ),

      body: ListView(

        padding:
            const EdgeInsets.all(
          16,
        ),

        children: [

          // ===================================================
          // HEADER
          // ===================================================

          const Text(

            'Financial Exports',

            style: TextStyle(

              fontSize: 24,

              fontWeight:
                  FontWeight.bold,
            ),
          ),

          const SizedBox(
            height: 6,
          ),

          const Text(

            'Generate professional reports and export financial data.',

            style: TextStyle(
              color: Colors.grey,
            ),
          ),

          const SizedBox(
            height: 24,
          ),

          // ===================================================
          // PDF SETTINGS
          // ===================================================

          Card(

            child: Padding(

              padding:
                  const EdgeInsets.all(
                16,
              ),

              child: Column(

                crossAxisAlignment:
                    CrossAxisAlignment
                        .start,

                children: [

                  Row(

                    children: [

                      const Icon(
                        Icons.picture_as_pdf,
                      ),

                      const SizedBox(
                        width: 8,
                      ),

                      const Text(

                        'PDF Report Settings',

                        style: TextStyle(

                          fontSize: 18,

                          fontWeight:
                              FontWeight
                                  .bold,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(
                    height: 20,
                  ),

                  TextField(

                    controller:
                        reportTitleController,

                    decoration:
                        const InputDecoration(

                      labelText:
                          'Report Title',

                      hintText:
                          'Enter report title',

                      border:
                          OutlineInputBorder(),

                      prefixIcon:
                          Icon(
                        Icons.title,
                      ),
                    ),
                  ),

                  const SizedBox(
                    height: 12,
                  ),

                  const Text(

                    'This title will appear at the top of the exported PDF report.',

                    style: TextStyle(
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(
            height: 24,
          ),

          // ===================================================
          // EXPORT OPTIONS
          // ===================================================

          const Text(

            'Export Options',

            style: TextStyle(

              fontSize: 18,

              fontWeight:
                  FontWeight.bold,
            ),
          ),

          const SizedBox(
            height: 16,
          ),

          // ===================================================
          // CSV EXPORT
          // ===================================================

          Card(

            child: ListTile(

              contentPadding:
                  const EdgeInsets.all(
                16,
              ),

              leading: Container(

                padding:
                    const EdgeInsets.all(
                  12,
                ),

                decoration:
                    BoxDecoration(

                  color:
                      Colors.green
                          .withValues(
                    alpha: 0.1,
                  ),

                  borderRadius:
                      BorderRadius.circular(
                    12,
                  ),
                ),

                child: const Icon(
                  Icons.table_chart,
                  color:
                      Colors.green,
                ),
              ),

              title: const Text(

                'Export CSV',

                style: TextStyle(

                  fontWeight:
                      FontWeight.bold,
                ),
              ),

              subtitle: const Padding(

                padding:
                    EdgeInsets.only(
                  top: 6,
                ),

                child: Text(
                  'Export all transactions in spreadsheet compatible CSV format.',
                ),
              ),

              trailing:
                  exporting

                      ? const SizedBox(

                          height: 24,
                          width: 24,

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

          const SizedBox(
            height: 16,
          ),

          // ===================================================
          // PDF EXPORT
          // ===================================================

          Card(

            child: ListTile(

              contentPadding:
                  const EdgeInsets.all(
                16,
              ),

              leading: Container(

                padding:
                    const EdgeInsets.all(
                  12,
                ),

                decoration:
                    BoxDecoration(

                  color:
                      Colors.red
                          .withValues(
                    alpha: 0.1,
                  ),

                  borderRadius:
                      BorderRadius.circular(
                    12,
                  ),
                ),

                child: const Icon(
                  Icons.picture_as_pdf,
                  color:
                      Colors.red,
                ),
              ),

              title: const Text(

                'Export PDF Report',

                style: TextStyle(

                  fontWeight:
                      FontWeight.bold,
                ),
              ),

              subtitle: const Padding(

                padding:
                    EdgeInsets.only(
                  top: 6,
                ),

                child: Text(
                  'Generate professional printable financial report.',
                ),
              ),

              trailing:
                  exporting

                      ? const SizedBox(

                          height: 24,
                          width: 24,

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
                      : exportPdf,
            ),
          ),

          const SizedBox(
            height: 32,
          ),
        ],
      ),
    );
  }
}