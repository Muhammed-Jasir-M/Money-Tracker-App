import 'package:flutter/material.dart';
import 'package:money_tracker_app/data/datasources/settings_local_datasource.dart';
import 'package:money_tracker_app/data/models/settings/app_settings.dart';

class SettingsRepository {
  SettingsRepository({required SettingsLocalDatasource datasource})
      : _datasource = datasource;

  final SettingsLocalDatasource _datasource;

  AppSettings getSettingsSync() {
    return _datasource.getSettings();
  }

  Future<AppSettings> getSettings() async {
    return _datasource.getSettings();
  }

  Future<AppSettings> updateThemeMode(ThemeMode themeMode) async {
    await _datasource.saveThemeMode(themeMode);
    return _datasource.getSettings();
  }

  Future<AppSettings> updateUserName(String userName) async {
    await _datasource.saveUserName(userName);
    return _datasource.getSettings();
  }

  Future<AppSettings> updateCurrencySymbol(String currencySymbol) async {
    await _datasource.saveCurrencySymbol(currencySymbol);
    return _datasource.getSettings();
  }

  Future<AppSettings> restoreSettings(AppSettings settings) async {
    await _datasource.saveAll(settings);
    return _datasource.getSettings();
  }
}
