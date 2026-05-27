import 'dart:io';

import 'package:path_provider/path_provider.dart';

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../../../../shared/models/transaction_model.dart';

class PdfExportService {

  Future<File>
      generateMonthlyReport({

    required List<
            TransactionModel>
        transactions,

    required double income,

    required double expense,

    required double balance,
  })
  async {

    final pdf =
        pw.Document();

    pdf.addPage(

      pw.MultiPage(

        pageFormat:
            PdfPageFormat.a4,

        build: (context) {

          return [

            // =====================================
            // TITLE
            // =====================================

            pw.Text(

              'Finance Report',

              style: pw.TextStyle(

                fontSize: 28,

                fontWeight:
                    pw.FontWeight.bold,
              ),
            ),

            pw.SizedBox(
              height: 8,
            ),

            pw.Text(
              'Generated on ${DateTime.now()}',
            ),

            pw.SizedBox(
              height: 24,
            ),

            // =====================================
            // SUMMARY
            // =====================================

            pw.Container(

              padding:
                  const pw.EdgeInsets.all(
                16,
              ),

              decoration:
                  pw.BoxDecoration(

                border:
                    pw.Border.all(),
              ),

              child: pw.Column(

                crossAxisAlignment:
                    pw.CrossAxisAlignment
                        .start,

                children: [

                  pw.Text(

                    'Financial Summary',

                    style:
                        pw.TextStyle(

                      fontWeight:
                          pw.FontWeight.bold,

                      fontSize: 18,
                    ),
                  ),

                  pw.SizedBox(
                    height: 12,
                  ),

                  pw.Text(
                    'Income: ₹${income.toStringAsFixed(2)}',
                  ),

                  pw.Text(
                    'Expense: ₹${expense.toStringAsFixed(2)}',
                  ),

                  pw.Text(
                    'Balance: ₹${balance.toStringAsFixed(2)}',
                  ),
                ],
              ),
            ),

            pw.SizedBox(
              height: 24,
            ),

            // =====================================
            // TRANSACTIONS
            // =====================================

            pw.Text(

              'Transactions',

              style: pw.TextStyle(

                fontWeight:
                    pw.FontWeight.bold,

                fontSize: 18,
              ),
            ),

            pw.SizedBox(
              height: 12,
            ),

            pw.TableHelper.fromTextArray(

              headers: [

                'Date',

                'Type',

                'Amount',

                'Notes',
              ],

              data: transactions
                  .map(
                (t) {

                  return [

                    '${t.transactionDate.day}/${t.transactionDate.month}/${t.transactionDate.year}',

                    t.type,

                    '₹${(t.amount / 100).toStringAsFixed(2)}',

                    t.notes ?? '',
                  ];
                },
              ).toList(),
            ),
          ];
        },
      ),
    );

    final dir =
        await getTemporaryDirectory();

    final file = File(
      '${dir.path}/finance_report.pdf',
    );

    await file.writeAsBytes(
      await pdf.save(),
    );

    return file;
  }
}