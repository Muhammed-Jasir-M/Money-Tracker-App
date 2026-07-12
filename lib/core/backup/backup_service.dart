import 'dart:convert';
import 'dart:io';

import 'package:archive/archive.dart';
import 'package:intl/intl.dart';
import 'package:money_tracker_app/core/constants/app_branding.dart';
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
import 'package:path/path.dart' as p;
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

  /// v1 = single JSON with optional base64 photos.
  /// v2 = ZIP with `data.json` + `receipts/` image files.
  static const backupVersion = 2;

  final TransactionRepository _transactionRepository;
  final CategoryRepository _categoryRepository;
  final BudgetRepository _budgetRepository;
  final SettingsRepository _settingsRepository;
  final ReceiptStorage _receiptStorage;

  Future<void> exportAndShare() async {
    final transactions = await _transactionRepository.getAll();
    final categories = await _categoryRepository.getAll();
    final budgets = await _budgetRepository.getAll();
    final settings = _settingsRepository.getSettingsSync();

    final archive = Archive();
    final receiptEntries = <MapEntry<String, List<int>>>[];

    final transactionMaps = <Map<String, dynamic>>[];
    for (final transaction in transactions) {
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
        final extension = _extensionFromPath(receiptFile.path);
        final archivePath = 'receipts/${transaction.tId}$extension';
        final bytes = await receiptFile.readAsBytes();
        receiptEntries.add(MapEntry(archivePath, bytes));
        json['receiptFile'] = archivePath;
      }

      transactionMaps.add(json);
    }

    final payload = {
      'version': backupVersion,
      'exportedAt': DateTime.now().toUtc().toIso8601String(),
      'settings': _settingsToJson(settings),
      'categories': categories.map(_categoryToJson).toList(),
      'budgets': budgets.map(_budgetToJson).toList(),
      'transactions': transactionMaps,
    };

    final jsonBytes = utf8.encode(
      const JsonEncoder.withIndent('  ').convert(payload),
    );
    archive.addFile(ArchiveFile('data.json', jsonBytes.length, jsonBytes));

    for (final entry in receiptEntries) {
      archive.addFile(
        ArchiveFile(entry.key, entry.value.length, entry.value),
      );
    }

    final zipBytes = ZipEncoder().encode(archive);
    if (zipBytes.isEmpty) {
      throw BackupException('Could not create backup archive');
    }

    final tempDir = await getTemporaryDirectory();
    final timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
    final file = File(
      p.join(tempDir.path, 'finora_backup_$timestamp.zip'),
    );
    await file.writeAsBytes(zipBytes, flush: true);

    await Share.shareXFiles(
      [XFile(file.path, mimeType: 'application/zip')],
      subject: '${AppBranding.displayName} backup',
      text: '${AppBranding.displayName} ZIP backup',
    );
  }

  Future<void> restoreFromFile(String filePath) async {
    final file = File(filePath);
    if (!await file.exists()) {
      throw BackupException('Backup file not found');
    }

    final lower = filePath.toLowerCase();
    if (lower.endsWith('.zip')) {
      await _restoreFromZip(await file.readAsBytes());
      return;
    }

    if (lower.endsWith('.json')) {
      await _restoreFromLegacyJson(await file.readAsString());
      return;
    }

    // Try ZIP first (some pickers omit extension), then JSON.
    final bytes = await file.readAsBytes();
    try {
      await _restoreFromZip(bytes);
    } on BackupException {
      try {
        await _restoreFromLegacyJson(utf8.decode(bytes));
      } catch (_) {
        throw BackupException(
          'Unsupported backup file. Use a .zip or .json backup.',
        );
      }
    }
  }

  Future<void> _restoreFromZip(List<int> bytes) async {
    Archive archive;
    try {
      archive = ZipDecoder().decodeBytes(bytes);
    } catch (_) {
      throw BackupException('Invalid ZIP backup file');
    }

    final dataFile = archive.findFile('data.json');
    if (dataFile == null) {
      throw BackupException('Backup ZIP is missing data.json');
    }

    final decoded = jsonDecode(utf8.decode(dataFile.content));
    if (decoded is! Map<String, dynamic>) {
      throw BackupException('Invalid backup file format');
    }

    _validateBackupPayload(decoded);

    final receiptBytesByPath = <String, List<int>>{};
    for (final file in archive.files) {
      if (!file.isFile) continue;
      final name = file.name.replaceAll('\\', '/');
      if (!name.startsWith('receipts/')) continue;
      final bytes = file.content;
      if (bytes.isNotEmpty) {
        receiptBytesByPath[name] = bytes;
      }
    }

    await _applyRestore(
      decoded,
      receiptBytesByArchivePath: receiptBytesByPath,
    );
  }

  Future<void> _restoreFromLegacyJson(String raw) async {
    final decoded = jsonDecode(raw);
    if (decoded is! Map<String, dynamic>) {
      throw BackupException('Invalid backup file format');
    }

    _validateBackupPayload(decoded);
    await _applyRestore(decoded);
  }

  void _validateBackupPayload(Map<String, dynamic> decoded) {
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
  }

  Future<void> _applyRestore(
    Map<String, dynamic> decoded, {
    Map<String, List<int>> receiptBytesByArchivePath = const {},
  }) async {
    final settingsJson = decoded['settings'] as Map<String, dynamic>;
    final categoriesJson = decoded['categories'] as List;
    final budgetsJson = decoded['budgets'] as List;
    final transactionsJson = decoded['transactions'] as List;

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
      if (item is Map) {
        final map = Map<String, dynamic>.from(item);
        final transaction = await _transactionFromJson(
          map,
          receiptBytesByArchivePath: receiptBytesByArchivePath,
        );
        await _transactionRepository.add(transaction);
      }
    }

    await _settingsRepository.restoreSettings(_settingsFromJson(settingsJson));
  }

  Map<String, dynamic> _settingsToJson(AppSettings settings) => {
        'themeMode': AppSettings.themeModeToString(settings.themeMode),
        'userName': settings.userName,
        'currencySymbol': settings.currencySymbol,
        'lockEnabled': settings.lockEnabled,
        'useBiometric': settings.useBiometric,
        'onboardingCompleted': settings.onboardingCompleted,
      };

  AppSettings _settingsFromJson(Map<String, dynamic> json) => AppSettings(
        themeMode: AppSettings.themeModeFromString(
          json['themeMode'] as String? ?? 'system',
        ),
        userName: json['userName'] as String? ?? '',
        currencySymbol: json['currencySymbol'] as String? ?? '₹',
        lockEnabled: json['lockEnabled'] as bool? ?? false,
        useBiometric: json['useBiometric'] as bool? ?? false,
        onboardingCompleted: json['onboardingCompleted'] as bool? ?? true,
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

  Future<TransactionModel> _transactionFromJson(
    Map<String, dynamic> json, {
    Map<String, List<int>> receiptBytesByArchivePath = const {},
  }) async {
    final transactionId = json['tId'] as String;
    var receiptPath = '';

    final receiptFile = json['receiptFile'] as String?;
    if (receiptFile != null && receiptFile.isNotEmpty) {
      final normalized = receiptFile.replaceAll('\\', '/');
      final bytes = receiptBytesByArchivePath[normalized];
      if (bytes != null && bytes.isNotEmpty) {
        receiptPath = await _receiptStorage.saveFromBytes(
              transactionId,
              bytes,
              extension: _extensionFromPath(normalized),
            ) ??
            '';
      }
    } else {
      // Legacy v1 JSON backups embedded photos as base64.
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
    final ext = p.extension(path);
    if (ext.isEmpty) return '.jpg';
    return ext;
  }
}
