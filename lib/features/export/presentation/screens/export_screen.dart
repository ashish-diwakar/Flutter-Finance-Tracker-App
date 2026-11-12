import 'dart:io';

import 'package:finance_tracker/core/utils/calendar_date.dart';
import 'package:finance_tracker/core/services/logger_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:isar_community/isar.dart';
import 'package:share_plus/share_plus.dart';

import '../../../../core/widgets/aurora_app_bar.dart';
import '../../../../shared/models/transaction_model.dart';
import '../../../../shared/providers/currency_provider.dart';
import '../../../../shared/providers/database_provider.dart';
import '../../data/services/csv_export_service.dart';
import '../../data/services/pdf_export_service.dart';
import '../../data/services/export_temporary_files.dart';
import '../../domain/export_report_style.dart';

enum ExportPeriodPreset {
  thisMonth('This Month'),
  lastMonth('Last Month'),
  thisYear('This Year'),
  allTime('All Time'),
  custom('Custom');

  const ExportPeriodPreset(this.label);

  final String label;
}

class ExportScreen extends ConsumerStatefulWidget {
  const ExportScreen({super.key});

  @override
  ConsumerState<ExportScreen> createState() => _ExportScreenState();
}

class _ExportScreenState extends ConsumerState<ExportScreen> {
  bool exporting = false;

  ExportReportStyle selectedStyle = ExportReportStyle.modern;

  ExportPeriodPreset selectedPeriod = ExportPeriodPreset.thisMonth;

  DateTime? customFromDate;
  DateTime? customToDate;

  final TextEditingController reportTitleController = TextEditingController(
    text: 'Monthly Financial Report',
  );

  DateTime _startOfDay(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  _ExportDateRange _resolveDateRange() {
    final now = DateTime.now();

    switch (selectedPeriod) {
      case ExportPeriodPreset.thisMonth:
        return _ExportDateRange(
          start: DateTime(now.year, now.month, 1),
          endExclusive: DateTime(now.year, now.month + 1, 1),
        );

      case ExportPeriodPreset.lastMonth:
        return _ExportDateRange(
          start: DateTime(now.year, now.month - 1, 1),
          endExclusive: DateTime(now.year, now.month, 1),
        );

      case ExportPeriodPreset.thisYear:
        return _ExportDateRange(
          start: DateTime(now.year, 1, 1),
          endExclusive: DateTime(now.year + 1, 1, 1),
        );

      case ExportPeriodPreset.allTime:
        return const _ExportDateRange();

      case ExportPeriodPreset.custom:
        final fromDate = customFromDate;
        final toDate = customToDate;

        if (fromDate == null || toDate == null) {
          return const _ExportDateRange();
        }

        final start = _startOfDay(fromDate);

        final toStart = _startOfDay(toDate);

        return _ExportDateRange(
          start: start,
          endExclusive: CalendarDate.addDays(toStart, 1),
        );
    }
  }

  String get selectedPeriodLabel {
    final range = _resolveDateRange();

    if (selectedPeriod == ExportPeriodPreset.allTime) {
      return 'All Time';
    }

    if (range.start == null || range.endExclusive == null) {
      return 'Select a valid date range';
    }

    final formatter = DateFormat('dd MMM yyyy');

    final endInclusive = CalendarDate.addDays(range.endExclusive!, -1);

    return '${formatter.format(range.start!)} – '
        '${formatter.format(endInclusive)}';
  }

  bool _validateExportPeriod() {
    if (selectedPeriod != ExportPeriodPreset.custom) {
      return true;
    }

    if (customFromDate == null || customToDate == null) {
      _showMessage('Please select both From Date and To Date.');
      return false;
    }

    final from = _startOfDay(customFromDate!);

    final to = _startOfDay(customToDate!);

    if (from.isAfter(to)) {
      _showMessage('From Date cannot be after To Date.');
      return false;
    }

    return true;
  }

  List<TransactionModel> _filterTransactions(
    List<TransactionModel> transactions,
  ) {
    final range = _resolveDateRange();

    return transactions.where((transaction) {
      final date = transaction.transactionDate.toLocal();

      if (range.start != null && date.isBefore(range.start!)) {
        return false;
      }

      if (range.endExclusive != null && !date.isBefore(range.endExclusive!)) {
        return false;
      }

      return true;
    }).toList();
  }

  Future<List<TransactionModel>> _loadExportTransactions() async {
    final isar = await ref.read(isarProvider.future);

    final transactions = await isar.transactionModels
        .filter()
        .isDeletedEqualTo(false)
        .sortByTransactionDateDesc()
        .findAll();

    return _filterTransactions(transactions);
  }

  void _showMessage(String message) {
    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  void _selectPeriod(ExportPeriodPreset period) {
    setState(() {
      selectedPeriod = period;

      if (period == ExportPeriodPreset.custom &&
          (customFromDate == null || customToDate == null)) {
        final now = DateTime.now();

        customFromDate = DateTime(now.year, now.month, 1);

        customToDate = DateTime(now.year, now.month, now.day);
      }
    });
  }

  Future<void> _pickCustomDate({required bool isFromDate}) async {
    final now = DateTime.now();

    final currentValue = isFromDate ? customFromDate : customToDate;

    final picked = await showDatePicker(
      context: context,
      initialDate: currentValue ?? now,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (picked == null || !mounted) {
      return;
    }

    setState(() {
      if (isFromDate) {
        customFromDate = picked;
      } else {
        customToDate = picked;
      }
    });
  }

  Future<void> exportCsv() async {
    if (!_validateExportPeriod()) {
      return;
    }

    setState(() {
      exporting = true;
    });

    final temporaryFiles = ExportTemporaryFiles();
    File? source;
    try {
      final isar = await ref.read(isarProvider.future);

      final transactions = await _loadExportTransactions();

      if (transactions.isEmpty) {
        _showMessage('No transactions found for the selected period.');
        return;
      }

      final service = CsvExportService(isar, temporaryFiles: temporaryFiles);

      source = await service.exportTransactions(transactions);

      await Share.shareXFiles([XFile(source.path)]);

      _showMessage('CSV exported successfully');
    } catch (e, s) {
      LoggerService.error('CSV EXPORT ERROR: $e');

      LoggerService.error('CSV EXPORT STACK: $s');

      _showMessage('Unable to export CSV');
    } finally {
      if (source != null) await temporaryFiles.cleanSource(source);
      if (mounted) {
        setState(() {
          exporting = false;
        });
      }
    }
  }

  Future<void> exportPdf() async {
    final reportTitle = reportTitleController.text.trim();

    if (reportTitle.isEmpty) {
      _showMessage('Please enter a PDF report title.');
      return;
    }

    if (!_validateExportPeriod()) {
      return;
    }

    setState(() {
      exporting = true;
    });

    final temporaryFiles = ExportTemporaryFiles();
    File? source;
    try {
      final isar = await ref.read(isarProvider.future);

      final transactions = await _loadExportTransactions();

      if (transactions.isEmpty) {
        _showMessage('No transactions found for the selected period.');
        return;
      }

      double income = 0;
      double expense = 0;

      for (final transaction in transactions) {
        if (transaction.type == 'income') {
          income += transaction.amount / 100;
        } else if (transaction.type == 'expense') {
          expense += transaction.amount / 100;
        }
      }

      final netIncome = income - expense;

      final currency = ref.read(currencyProvider);

      final service = PdfExportService(isar, temporaryFiles: temporaryFiles);

      source = await service.generateMonthlyReport(
        reportTitle: reportTitle,
        reportPeriod: selectedPeriodLabel,
        style: selectedStyle,
        currencySymbol: currency.symbol,
        transactions: transactions,
        income: income,
        expense: expense,
        balance: netIncome,
      );

      await Share.shareXFiles([XFile(source.path)]);

      _showMessage('PDF exported successfully');
    } catch (e, s) {
      LoggerService.error('PDF EXPORT ERROR: $e');

      LoggerService.error('PDF EXPORT STACK: $s');

      _showMessage('Unable to export PDF: $e');
    } finally {
      if (source != null) await temporaryFiles.cleanSource(source);
      if (mounted) {
        setState(() {
          exporting = false;
        });
      }
    }
  }

  @override
  void dispose() {
    reportTitleController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dateFormatter = DateFormat('dd MMM yyyy');

    return Scaffold(
      appBar: const AuroraAppBar(title: Text('Export & Reports')),
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
          ListView(
            padding: const EdgeInsets.all(16),
            children: [
              const Text(
                'Financial Exports',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 6),
              const Text(
                'Generate professional reports and export financial data.',
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 24),

              // ==========================================
              // EXPORT PERIOD
              // ==========================================
              Card(
                margin: EdgeInsets.zero,
                color: const Color(0xFFF0F8F2),
                surfaceTintColor: Colors.transparent,
                elevation: 1,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                  side: const BorderSide(color: Color(0xFFB8D8CA)),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(15),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.date_range),
                          SizedBox(width: 8),
                          Text(
                            'Export Period',
                            style: TextStyle(
                              color: Color(0xFF315F53),
                              fontSize: 17,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Choose the transaction period to include in both CSV and PDF exports.',
                        style: TextStyle(
                          color: Color(0xFF536B61),
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: ExportPeriodPreset.values.map((period) {
                          return ChoiceChip(
                            label: Text(period.label),
                            selected: selectedPeriod == period,
                            showCheckmark: true,
                            selectedColor: const Color(0xFFDDEFE5),
                            backgroundColor: const Color(0xFFFAFDFB),
                            side: BorderSide(
                              color: selectedPeriod == period
                                  ? const Color(0xFF3E8877)
                                  : const Color(0xFFB5D9CA),
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 8,
                            ),
                            labelStyle: TextStyle(
                              color: const Color(0xFF315F53),
                              fontWeight: selectedPeriod == period
                                  ? FontWeight.w600
                                  : FontWeight.w500,
                            ),
                            onSelected: (_) => _selectPeriod(period),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 16),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE5F1E9),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.calendar_month,
                              size: 20,
                              color: Color(0xFF315F53),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                selectedPeriodLabel,
                                style: const TextStyle(
                                  color: Color(0xFF244C40),
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (selectedPeriod == ExportPeriodPreset.custom) ...[
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: _DateRangeButton(
                                label: 'From Date',
                                value: customFromDate == null
                                    ? 'Select'
                                    : dateFormatter.format(customFromDate!),
                                onTap: () => _pickCustomDate(isFromDate: true),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _DateRangeButton(
                                label: 'To Date',
                                value: customToDate == null
                                    ? 'Select'
                                    : dateFormatter.format(customToDate!),
                                onTap: () => _pickCustomDate(isFromDate: false),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // ==========================================
              // PDF SETTINGS
              // ==========================================
              Card(
                margin: EdgeInsets.zero,
                color: const Color(0xFFF0F8F2),
                surfaceTintColor: Colors.transparent,
                elevation: 1,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                  side: const BorderSide(color: Color(0xFFB8D8CA)),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(15),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.picture_as_pdf),
                          SizedBox(width: 8),
                          Text(
                            'PDF Report Settings',
                            style: TextStyle(
                              color: Color(0xFF315F53),
                              fontSize: 17,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      TextField(
                        controller: reportTitleController,
                        style: const TextStyle(
                          color: Color(0xFF244C40),
                          fontSize: 18,
                        ),
                        decoration: InputDecoration(
                          labelText: 'PDF Report Title',
                          labelStyle: const TextStyle(
                            color: Color(0xFF536B61),
                            fontWeight: FontWeight.w600,
                          ),
                          floatingLabelStyle: const TextStyle(
                            color: Color(0xFF315F53),
                            fontWeight: FontWeight.w600,
                          ),
                          hintText: 'Enter the heading for your PDF report',
                          hintStyle: const TextStyle(color: Color(0xFF6B7F76)),
                          helperText:
                              'Enter the heading that will appear at the top of the PDF. You can keep or change this title.',
                          helperMaxLines: 2,
                          helperStyle: const TextStyle(
                            color: Color(0xFF536B61),
                            fontSize: 13,
                          ),
                          filled: true,
                          fillColor: const Color(0xFFFAFDFB),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 15,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: const BorderSide(
                              color: Color(0xFFB5D9CA),
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: const BorderSide(
                              color: Color(0xFF3E8877),
                              width: 1.6,
                            ),
                          ),
                          prefixIcon: const Icon(Icons.title),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // ==========================================
              // REPORT STYLE
              // ==========================================
              Card(
                margin: EdgeInsets.zero,
                color: const Color(0xFFF0F8F2),
                surfaceTintColor: Colors.transparent,
                elevation: 1,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                  side: const BorderSide(color: Color(0xFFB8D8CA)),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(15),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Report Style',
                        style: TextStyle(
                          color: Color(0xFF315F53),
                          fontSize: 17,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 16),
                      SegmentedButton<ExportReportStyle>(
                        showSelectedIcon: true,
                        segments: const [
                          ButtonSegment(
                            value: ExportReportStyle.classic,
                            label: Text('Classic'),
                            icon: Icon(Icons.description),
                          ),
                          ButtonSegment(
                            value: ExportReportStyle.modern,
                            label: Text('Modern'),
                            icon: Icon(Icons.auto_graph),
                          ),
                        ],
                        selected: {selectedStyle},
                        style: ButtonStyle(
                          backgroundColor: WidgetStateProperty.resolveWith((
                            states,
                          ) {
                            if (states.contains(WidgetState.selected)) {
                              return const Color(0xFFDDEFE5);
                            }
                            return const Color(0xFFFAFDFB);
                          }),
                          foregroundColor: WidgetStateProperty.all(
                            const Color(0xFF315F53),
                          ),
                          side: WidgetStateProperty.resolveWith((states) {
                            return BorderSide(
                              color: states.contains(WidgetState.selected)
                                  ? const Color(0xFF3E8877)
                                  : const Color(0xFFB5D9CA),
                            );
                          }),
                          shape: WidgetStateProperty.all(
                            RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          textStyle: WidgetStateProperty.all(
                            const TextStyle(fontWeight: FontWeight.w600),
                          ),
                          minimumSize: WidgetStateProperty.all(
                            const Size(0, 48),
                          ),
                        ),
                        onSelectionChanged: (value) {
                          setState(() {
                            selectedStyle = value.first;
                          });
                        },
                      ),
                      const SizedBox(height: 14),
                      Text(
                        selectedStyle == ExportReportStyle.classic
                            ? 'Simple printable financial report with compact layout.'
                            : 'Modern analytics-style report with summary cards and insights.',
                        style: const TextStyle(
                          color: Color(0xFF536B61),
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // ==========================================
              // EXPORT OPTIONS
              // ==========================================
              const Text(
                'Export Options',
                style: TextStyle(
                  color: Color(0xFF315F53),
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 16),

              Card(
                margin: EdgeInsets.zero,
                color: const Color(0xFFF1F8F2),
                surfaceTintColor: Colors.transparent,
                elevation: 1,
                clipBehavior: Clip.antiAlias,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                  side: const BorderSide(color: Color(0xFFA8CFC0)),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(15),
                  minVerticalPadding: 14,
                  leading: Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: const Color(0xFFDFF1E5),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    alignment: Alignment.center,
                    child: const Icon(
                      Icons.table_chart,
                      color: Color(0xFF237F50),
                      size: 24,
                    ),
                  ),
                  title: const Text(
                    'Export CSV',
                    style: TextStyle(
                      color: Color(0xFF244D40),
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  subtitle: const Padding(
                    padding: EdgeInsets.only(top: 6),
                    child: Text(
                      'Export transactions from the selected period in spreadsheet-compatible CSV format.',
                      style: TextStyle(color: Color(0xFF536B61), fontSize: 14),
                    ),
                  ),
                  trailing: exporting
                      ? const SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(
                          Icons.chevron_right,
                          color: Color(0xFF17664F),
                          size: 24,
                        ),
                  onTap: exporting ? null : exportCsv,
                ),
              ),

              const SizedBox(height: 16),

              Card(
                margin: EdgeInsets.zero,
                color: const Color(0xFFF1F8F2),
                surfaceTintColor: Colors.transparent,
                elevation: 1,
                clipBehavior: Clip.antiAlias,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                  side: const BorderSide(color: Color(0xFFA8CFC0)),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(15),
                  minVerticalPadding: 14,
                  leading: Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFBE8E3),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    alignment: Alignment.center,
                    child: const Icon(
                      Icons.picture_as_pdf,
                      color: Color(0xFFB54C44),
                      size: 24,
                    ),
                  ),
                  title: const Text(
                    'Export PDF Report',
                    style: TextStyle(
                      color: Color(0xFF244D40),
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  subtitle: const Padding(
                    padding: EdgeInsets.only(top: 6),
                    child: Text(
                      'Generate a professional PDF report for the selected period.',
                      style: TextStyle(color: Color(0xFF536B61), fontSize: 14),
                    ),
                  ),
                  trailing: exporting
                      ? const SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(
                          Icons.chevron_right,
                          color: Color(0xFF17664F),
                          size: 24,
                        ),
                  onTap: exporting ? null : exportPdf,
                ),
              ),

              const SizedBox(height: 64),
            ],
          ),
        ],
      ),
    );
  }
}

class _ExportDateRange {
  final DateTime? start;
  final DateTime? endExclusive;

  const _ExportDateRange({this.start, this.endExclusive});
}

class _DateRangeButton extends StatelessWidget {
  const _DateRangeButton({
    required this.label,
    required this.value,
    required this.onTap,
  });

  final String label;
  final String value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Color(0xFF536B61)),
          filled: true,
          fillColor: const Color(0xFFFAFDFB),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 14,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: Color(0xFFB5D9CA)),
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: Color(0xFFB5D9CA)),
          ),
          suffixIcon: const Icon(
            Icons.calendar_today,
            size: 18,
            color: Color(0xFF315F53),
          ),
        ),
        child: Text(
          value,
          style: const TextStyle(
            color: Color(0xFF244C40),
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
