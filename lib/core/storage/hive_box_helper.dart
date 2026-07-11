import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';

Future<Box<T>> openBoxSafely<T>(String name) async {
  try {
    if (Hive.isBoxOpen(name)) {
      return Hive.box<T>(name);
    }
    return await Hive.openBox<T>(name);
  } on HiveError catch (error) {
    debugPrint('Hive box "$name" failed to open: $error');
    if (Hive.isBoxOpen(name)) {
      await Hive.box(name).close();
    }
    await Hive.deleteBoxFromDisk(name);
    return Hive.openBox<T>(name);
  }
}

Future<Box> openUntypedBoxSafely(String name) async {
  try {
    if (Hive.isBoxOpen(name)) {
      return Hive.box(name);
    }
    return await Hive.openBox(name);
  } on HiveError catch (error) {
    debugPrint('Hive box "$name" failed to open: $error');
    if (Hive.isBoxOpen(name)) {
      await Hive.box(name).close();
    }
    await Hive.deleteBoxFromDisk(name);
    return Hive.openBox(name);
  }
}
