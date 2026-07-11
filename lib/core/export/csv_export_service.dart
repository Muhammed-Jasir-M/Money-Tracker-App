import 'dart:io';

import 'package:csv/csv.dart';
import 'package:intl/intl.dart';
import 'package:money_tracker_app/data/models/transaction/transaction_model.dart';
import 'package:money_tracker_app/data/repositories/transaction_repository.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

class CsvExportException implements Exception {
  CsvExportException(this.message);

  final String message;

  @override
  String toString() => message;
}

class CsvExportService {
  CsvExportService({required TransactionRepository transactionRepository})
      : _transactionRepository = transactionRepository;

  final TransactionRepository _transactionRepository;

  static const _headers = [
    'Date',
    'Time',
    'Type',
    'Category',
    'Amount',
    'Currency',
    'Note',
    'Has Receipt',
    'Transaction ID',
  ];

  Future<void> exportAndShare({required String currencySymbol}) async {
    final transactions = await _transactionRepository.getAll();
    transactions.sort((a, b) => b.dateTime.compareTo(a.dateTime));

    final rows = <List<dynamic>>[
      _headers,
      ...transactions.map(
        (transaction) => _transactionToRow(transaction, currencySymbol),
      ),
    ];

    final csv = const ListToCsvConverter().convert(rows);
    final tempDir = await getTemporaryDirectory();
    final timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
    final file = File('${tempDir.path}/money_tracker_transactions_$timestamp.csv');
    await file.writeAsString(csv);

    await Share.shareXFiles(
      [XFile(file.path, mimeType: 'text/csv')],
      subject: 'Money Tracker transactions',
      text: 'Transaction export (${transactions.length} rows)',
    );
  }

  List<dynamic> _transactionToRow(
    TransactionModel transaction,
    String currencySymbol,
  ) {
    return [
      DateFormat('yyyy-MM-dd').format(transaction.dateTime),
      DateFormat('HH:mm').format(transaction.dateTime),
      transaction.type.name,
      transaction.category.title,
      transaction.amount.toStringAsFixed(2),
      currencySymbol,
      transaction.note,
      transaction.hasReceipt ? 'yes' : 'no',
      transaction.tId,
    ];
  }
}
