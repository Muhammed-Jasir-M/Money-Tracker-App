import 'dart:convert';
import 'dart:io';

import 'package:intl/intl.dart';
import 'package:money_tracker_app/core/storage/receipt_storage.dart';
import 'package:money_tracker_app/data/models/budget/budget_model.dart';
import 'package:money_tracker_app/data/models/category/category_model.dart';
import 'package:money_tracker_app/data/models/enum/enum.dart';
import 'package:money_tracker_app/data/models/settings/app_settings.dart';
import 'package:money_tracker_app/data/models/transaction/transaction_model.dart';
import 'package:money_tracker_app/data/repositories/budget_repository.dart';
import 'package:money_tracker_app/data/repositories/category_repository.dart';
import 'package:money_tracker_app/data/repositories/settings_repository.dart';
import 'package:money_tracker_app/data/repositories/transaction_repository.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

class BackupException implements Exception {
  BackupException(this.message);

  final String message;

  @override
  String toString() => message;
}

class BackupService {
  BackupService({
    required TransactionRepository transactionRepository,
    required CategoryRepository categoryRepository,
    required BudgetRepository budgetRepository,
    required SettingsRepository settingsRepository,
    ReceiptStorage? receiptStorage,
  })  : _transactionRepository = transactionRepository,
        _categoryRepository = categoryRepository,
        _budgetRepository = budgetRepository,
        _settingsRepository = settingsRepository,
        _receiptStorage = receiptStorage ?? ReceiptStorage();

  static const backupVersion = 1;

  final TransactionRepository _transactionRepository;
  final CategoryRepository _categoryRepository;
  final BudgetRepository _budgetRepository;
  final SettingsRepository _settingsRepository;
  final ReceiptStorage _receiptStorage;

  Future<void> exportAndShare() async {
    final payload = await _buildBackupMap();
    final encoded = const JsonEncoder.withIndent('  ').convert(payload);

    final tempDir = await getTemporaryDirectory();
    final timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
    final file = File('${tempDir.path}/money_tracker_backup_$timestamp.json');
    await file.writeAsString(encoded);

    await Share.shareXFiles(
      [XFile(file.path)],
      subject: 'Money Tracker backup',
      text: 'Money Tracker data backup',
    );
  }

  Future<void> restoreFromFile(String filePath) async {
    final file = File(filePath);
    if (!await file.exists()) {
      throw BackupException('Backup file not found');
    }

    final decoded = jsonDecode(await file.readAsString());
    if (decoded is! Map<String, dynamic>) {
      throw BackupException('Invalid backup file format');
    }

    final version = decoded['version'];
    if (version is! int || version > backupVersion) {
      throw BackupException('Unsupported backup version');
    }

    final settingsJson = decoded['settings'];
    final categoriesJson = decoded['categories'];
    final budgetsJson = decoded['budgets'];
    final transactionsJson = decoded['transactions'];

    if (settingsJson is! Map<String, dynamic> ||
        categoriesJson is! List ||
        budgetsJson is! List ||
        transactionsJson is! List) {
      throw BackupException('Backup file is missing required data');
    }

    await _receiptStorage.clearAll();
    await _transactionRepository.clearAll();
    await _categoryRepository.clearAll();
    await _budgetRepository.clearAll();

    for (final item in categoriesJson) {
      if (item is Map<String, dynamic>) {
        await _categoryRepository.add(_categoryFromJson(item));
      }
    }

    for (final item in budgetsJson) {
      if (item is Map<String, dynamic>) {
        await _budgetRepository.add(_budgetFromJson(item));
      }
    }

    for (final item in transactionsJson) {
      if (item is Map<String, dynamic>) {
        final transaction = await _transactionFromJson(item);
        await _transactionRepository.add(transaction);
      }
    }

    await _settingsRepository.restoreSettings(_settingsFromJson(settingsJson));
  }

  Future<Map<String, dynamic>> _buildBackupMap() async {
    final transactions = await _transactionRepository.getAll();
    final categories = await _categoryRepository.getAll();
    final budgets = await _budgetRepository.getAll();
    final settings = _settingsRepository.getSettingsSync();

    return {
      'version': backupVersion,
      'exportedAt': DateTime.now().toUtc().toIso8601String(),
      'settings': _settingsToJson(settings),
      'categories': categories.map(_categoryToJson).toList(),
      'budgets': budgets.map(_budgetToJson).toList(),
      'transactions': await Future.wait(
        transactions.map(_transactionToJson),
      ),
    };
  }

  Map<String, dynamic> _settingsToJson(AppSettings settings) => {
        'themeMode': AppSettings.themeModeToString(settings.themeMode),
        'userName': settings.userName,
        'currencySymbol': settings.currencySymbol,
        'lockEnabled': settings.lockEnabled,
        'useBiometric': settings.useBiometric,
      };

  AppSettings _settingsFromJson(Map<String, dynamic> json) => AppSettings(
        themeMode: AppSettings.themeModeFromString(
          json['themeMode'] as String? ?? 'system',
        ),
        userName: json['userName'] as String? ?? '',
        currencySymbol: json['currencySymbol'] as String? ?? '₹',
        lockEnabled: json['lockEnabled'] as bool? ?? false,
        useBiometric: json['useBiometric'] as bool? ?? false,
      );

  Map<String, dynamic> _categoryToJson(CategoryModel category) => {
        'cId': category.cId,
        'title': category.title,
        'iconIndex': category.iconIndex,
        'color': category.color,
        'type': category.type.name,
      };

  CategoryModel _categoryFromJson(Map<String, dynamic> json) => CategoryModel(
        cId: json['cId'] as String,
        title: json['title'] as String,
        iconIndex: json['iconIndex'] as int,
        color: json['color'] as int,
        type: TransactionType.values.byName(json['type'] as String),
      );

  Map<String, dynamic> _budgetToJson(BudgetModel budget) => {
        'bId': budget.bId,
        'categoryId': budget.categoryId,
        'amountLimit': budget.amountLimit,
      };

  BudgetModel _budgetFromJson(Map<String, dynamic> json) => BudgetModel(
        bId: json['bId'] as String,
        categoryId: json['categoryId'] as String?,
        amountLimit: (json['amountLimit'] as num).toDouble(),
      );

  Future<Map<String, dynamic>> _transactionToJson(
    TransactionModel transaction,
  ) async {
    final json = <String, dynamic>{
      'tId': transaction.tId,
      'category': _categoryToJson(transaction.category),
      'type': transaction.type.name,
      'amount': transaction.amount,
      'dateTime': transaction.dateTime.toUtc().toIso8601String(),
      'note': transaction.note,
    };

        final receiptFile = _receiptStorage.fileAt(transaction.receiptPath);
    if (receiptFile != null) {
      final bytes = await receiptFile.readAsBytes();
      json['receiptBase64'] = base64Encode(bytes);
      json['receiptExtension'] = _extensionFromPath(receiptFile.path);
    }

    return json;
  }

  Future<TransactionModel> _transactionFromJson(
    Map<String, dynamic> json,
  ) async {
    final transactionId = json['tId'] as String;
    var receiptPath = json['receiptPath'] as String? ?? '';

    final receiptBase64 = json['receiptBase64'] as String?;
    if (receiptBase64 != null && receiptBase64.isNotEmpty) {
      final bytes = base64Decode(receiptBase64);
      final extension = json['receiptExtension'] as String? ?? '.jpg';
      receiptPath = await _receiptStorage.saveFromBytes(
            transactionId,
            bytes,
            extension: extension,
          ) ??
          '';
    }

    return TransactionModel(
      tId: transactionId,
      category: _categoryFromJson(json['category'] as Map<String, dynamic>),
      type: TransactionType.values.byName(json['type'] as String),
      amount: (json['amount'] as num).toDouble(),
      dateTime: DateTime.parse(json['dateTime'] as String).toLocal(),
      note: json['note'] as String? ?? '',
      receiptPath: receiptPath,
    );
  }

  String _extensionFromPath(String path) {
    final dotIndex = path.lastIndexOf('.');
    if (dotIndex == -1) return '.jpg';
    return path.substring(dotIndex);
  }
}
