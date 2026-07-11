import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

class ReceiptStorage {
  static const _folderName = 'receipts';

  Future<Directory> _receiptsDir() async {
    final appDir = await getApplicationDocumentsDirectory();
    final dir = Directory(p.join(appDir.path, _folderName));
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    return dir;
  }

  Future<String?> saveFromPath(String transactionId, String sourcePath) async {
    final source = File(sourcePath);
    if (!await source.exists()) return null;

    final ext = p.extension(sourcePath).isEmpty ? '.jpg' : p.extension(sourcePath);
    final dir = await _receiptsDir();
    await deleteForTransaction(transactionId);

    final destPath = p.join(dir.path, '$transactionId$ext');
    await source.copy(destPath);
    return destPath;
  }

  Future<String?> saveFromBytes(
    String transactionId,
    List<int> bytes, {
    String extension = '.jpg',
  }) async {
    if (bytes.isEmpty) return null;

    final ext = extension.startsWith('.') ? extension : '.$extension';
    final dir = await _receiptsDir();
    await deleteForTransaction(transactionId);

    final destPath = p.join(dir.path, '$transactionId$ext');
    await File(destPath).writeAsBytes(bytes);
    return destPath;
  }

  Future<void> deleteForTransaction(String transactionId) async {
    final dir = await _receiptsDir();
    await for (final entity in dir.list()) {
      if (entity is File &&
          p.basenameWithoutExtension(entity.path) == transactionId) {
        await entity.delete();
      }
    }
  }

  Future<void> clearAll() async {
    final appDir = await getApplicationDocumentsDirectory();
    final dir = Directory(p.join(appDir.path, _folderName));
    if (await dir.exists()) {
      await dir.delete(recursive: true);
    }
  }

  File? fileAt(String? path) {
    if (path == null || path.isEmpty) return null;
    final file = File(path);
    return file.existsSync() ? file : null;
  }

  bool existsAt(String? path) => fileAt(path) != null;
}
