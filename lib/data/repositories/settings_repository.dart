import 'package:flutter/material.dart';
import 'package:money_tracker_app/data/datasources/settings_local_datasource.dart';
import 'package:money_tracker_app/data/models/settings/app_settings.dart';

class SettingsRepository {
  SettingsRepository({required SettingsLocalDatasource datasource})
      : _datasource = datasource;

  final SettingsLocalDatasource _datasource;

  Future<AppSettings> getSettings() async {
    return _datasource.getSettings();
  }

  Future<AppSettings> updateThemeMode(ThemeMode themeMode) async {
    await _datasource.saveThemeMode(themeMode);
    return _datasource.getSettings();
  }
}
