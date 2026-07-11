import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:money_tracker_app/data/models/settings/app_settings.dart';

class SettingsLocalDatasource {
  SettingsLocalDatasource({required Box box}) : _box = box;

  final Box _box;

  static const _themeKey = 'themeMode';

  AppSettings getSettings() {
    final themeValue = _box.get(_themeKey, defaultValue: 'system') as String;

    return AppSettings(
      themeMode: AppSettings.themeModeFromString(themeValue),
    );
  }

  Future<void> saveThemeMode(ThemeMode themeMode) async {
    await _box.put(_themeKey, AppSettings.themeModeToString(themeMode));
  }
}
