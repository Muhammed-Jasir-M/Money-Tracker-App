import 'dart:io';

import 'package:csv/csv.dart';
import 'package:intl/intl.dart';
import 'package:money_tracker_app/core/constants/app_branding.dart';
import 'package:money_tracker_app/core/utils/money_format.dart';
import 'package:money_tracker_app/data/models/enum/enum.dart';
import 'package:money_tracker_app/data/models/transaction/transaction_model.dart';
import 'package:money_tracker_app/data/repositories/transaction_repository.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:share_plus/share_plus.dart';

class MonthlyReportException implements Exception {
  MonthlyReportException(this.message);

  final String message;

  @override
  String toString() => message;
}

class MonthlyReportService {
  MonthlyReportService({required TransactionRepository transactionRepository})
      : _transactionRepository = transactionRepository;

  final TransactionRepository _transactionRepository;

  static const _csvHeaders = [
    'Date',
    'Time',
    'Type',
    'Category',
    'Amount',
    'Currency',
    'Note',
    'Has Photo',
    'Transaction ID',
  ];

  Future<void> exportMonthAndShare({
    required DateTime month,
    required String currencySymbol,
  }) async {
    final monthStart = DateTime(month.year, month.month);
    final monthEnd = DateTime(month.year, month.month + 1);

    final all = await _transactionRepository.getAll();
    final transactions = all
        .where(
          (t) =>
              !t.dateTime.isBefore(monthStart) && t.dateTime.isBefore(monthEnd),
        )
        .toList()
      ..sort((a, b) => a.dateTime.compareTo(b.dateTime));

    final label = DateFormat('yyyy-MM').format(monthStart);
    final titleLabel = DateFormat('MMMM yyyy').format(monthStart);

    final income = transactions
        .where((t) => t.type == TransactionType.income)
        .fold<double>(0, (sum, t) => sum + t.amount);
    final expense = transactions
        .where((t) => t.type == TransactionType.expense)
        .fold<double>(0, (sum, t) => sum + t.amount);
    final balance = income - expense;

    final tempDir = await getTemporaryDirectory();
    final stamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());

    final csvFile = File(
      p.join(tempDir.path, 'finora_report_${label}_$stamp.csv'),
    );
    await csvFile.writeAsString(
      _buildCsv(
        transactions: transactions,
        currencySymbol: currencySymbol,
        income: income,
        expense: expense,
        balance: balance,
        titleLabel: titleLabel,
      ),
    );

    final pdfFile = File(
      p.join(tempDir.path, 'finora_report_${label}_$stamp.pdf'),
    );
    final pdfBytes = await _buildPdf(
      transactions: transactions,
      currencySymbol: currencySymbol,
      income: income,
      expense: expense,
      balance: balance,
      titleLabel: titleLabel,
    );
    await pdfFile.writeAsBytes(pdfBytes, flush: true);

    await Share.shareXFiles(
      [
        XFile(csvFile.path, mimeType: 'text/csv'),
        XFile(pdfFile.path, mimeType: 'application/pdf'),
      ],
      subject: '${AppBranding.displayName} report · $titleLabel',
      text:
          '$titleLabel report: ${transactions.length} transactions · CSV + PDF',
    );
  }

  String _buildCsv({
    required List<TransactionModel> transactions,
    required String currencySymbol,
    required double income,
    required double expense,
    required double balance,
    required String titleLabel,
  }) {
    final rows = <List<dynamic>>[
      ['Report', titleLabel],
      ['App', AppBranding.displayName],
      ['Income', income.toStringAsFixed(2)],
      ['Expense', expense.toStringAsFixed(2)],
      ['Balance', balance.toStringAsFixed(2)],
      ['Currency', currencySymbol],
      ['Transaction count', transactions.length],
      <dynamic>[],
      _csvHeaders,
      ...transactions.map(
        (transaction) => [
          DateFormat('yyyy-MM-dd').format(transaction.dateTime),
          DateFormat('HH:mm').format(transaction.dateTime),
          transaction.type.name,
          transaction.category.title,
          transaction.amount.toStringAsFixed(2),
          currencySymbol,
          transaction.note,
          transaction.hasReceipt ? 'yes' : 'no',
          transaction.tId,
        ],
      ),
    ];

    return const ListToCsvConverter().convert(rows);
  }

  Future<List<int>> _buildPdf({
    required List<TransactionModel> transactions,
    required String currencySymbol,
    required double income,
    required double expense,
    required double balance,
    required String titleLabel,
  }) async {
    final doc = pw.Document();
    final dateFmt = DateFormat('dd MMM yyyy');
    final timeFmt = DateFormat('HH:mm');

    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        header: (context) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(
              AppBranding.displayName,
              style: pw.TextStyle(
                fontSize: 11,
                color: PdfColors.blueGrey600,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
            pw.SizedBox(height: 4),
            pw.Text(
              'Monthly report · $titleLabel',
              style: pw.TextStyle(
                fontSize: 18,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
            pw.SizedBox(height: 12),
            pw.Divider(color: PdfColors.grey400),
            pw.SizedBox(height: 8),
          ],
        ),
        footer: (context) => pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Text(
              'Generated ${DateFormat('yyyy-MM-dd HH:mm').format(DateTime.now())}',
              style: const pw.TextStyle(
                fontSize: 9,
                color: PdfColors.grey600,
              ),
            ),
            pw.Text(
              'Page ${context.pageNumber} of ${context.pagesCount}',
              style: const pw.TextStyle(
                fontSize: 9,
                color: PdfColors.grey600,
              ),
            ),
          ],
        ),
        build: (context) => [
          pw.Container(
            padding: const pw.EdgeInsets.all(12),
            decoration: pw.BoxDecoration(
              color: PdfColors.grey100,
              borderRadius: pw.BorderRadius.circular(8),
            ),
            child: pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
              children: [
                _summaryCell('Income', income, currencySymbol),
                _summaryCell('Expense', expense, currencySymbol),
                _summaryCell('Balance', balance, currencySymbol),
              ],
            ),
          ),
          pw.SizedBox(height: 8),
          pw.Text(
            '${transactions.length} transaction${transactions.length == 1 ? '' : 's'}',
            style: const pw.TextStyle(
              fontSize: 11,
              color: PdfColors.grey700,
            ),
          ),
          pw.SizedBox(height: 16),
          if (transactions.isEmpty)
            pw.Text(
              'No transactions in this month.',
              style: const pw.TextStyle(fontSize: 12),
            )
          else
            pw.TableHelper.fromTextArray(
              headers: const [
                'Date',
                'Type',
                'Category',
                'Amount',
                'Note',
              ],
              data: transactions
                  .map(
                    (t) => [
                      '${dateFmt.format(t.dateTime)}\n${timeFmt.format(t.dateTime)}',
                      t.type.name,
                      t.category.title,
                      MoneyFormat.amount(t.amount, currencySymbol),
                      t.note.isEmpty ? '—' : t.note,
                    ],
                  )
                  .toList(),
              headerStyle: pw.TextStyle(
                fontWeight: pw.FontWeight.bold,
                fontSize: 10,
                color: PdfColors.white,
              ),
              headerDecoration: const pw.BoxDecoration(
                color: PdfColors.blueGrey700,
              ),
              cellStyle: const pw.TextStyle(fontSize: 9),
              cellAlignments: {
                0: pw.Alignment.centerLeft,
                1: pw.Alignment.center,
                2: pw.Alignment.centerLeft,
                3: pw.Alignment.centerRight,
                4: pw.Alignment.centerLeft,
              },
              columnWidths: {
                0: const pw.FlexColumnWidth(1.4),
                1: const pw.FlexColumnWidth(0.9),
                2: const pw.FlexColumnWidth(1.3),
                3: const pw.FlexColumnWidth(1.1),
                4: const pw.FlexColumnWidth(2.0),
              },
              rowDecoration: const pw.BoxDecoration(
                border: pw.Border(
                  bottom: pw.BorderSide(color: PdfColors.grey300, width: 0.5),
                ),
              ),
              cellPadding: const pw.EdgeInsets.symmetric(
                horizontal: 4,
                vertical: 6,
              ),
            ),
        ],
      ),
    );

    return doc.save();
  }

  pw.Widget _summaryCell(String label, double value, String symbol) {
    return pw.Column(
      children: [
        pw.Text(
          label,
          style: const pw.TextStyle(
            fontSize: 10,
            color: PdfColors.grey700,
          ),
        ),
        pw.SizedBox(height: 4),
        pw.Text(
          MoneyFormat.amount(value, symbol),
          style: pw.TextStyle(
            fontSize: 13,
            fontWeight: pw.FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
