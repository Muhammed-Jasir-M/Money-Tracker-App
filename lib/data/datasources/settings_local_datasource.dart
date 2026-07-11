import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:money_tracker_app/core/constants/currencies.dart';
import 'package:money_tracker_app/data/models/settings/app_settings.dart';

class SettingsLocalDatasource {
  SettingsLocalDatasource({required Box box}) : _box = box;

  final Box _box;

  static const _themeKey = 'themeMode';
  static const _userNameKey = 'userName';
  static const _currencySymbolKey = 'currencySymbol';

  AppSettings getSettings() {
    final themeValue = _box.get(_themeKey, defaultValue: 'system') as String;
    final userName = _box.get(_userNameKey, defaultValue: '') as String;
    final currencySymbol =
        _box.get(_currencySymbolKey, defaultValue: CurrencyOptions.defaultSymbol)
            as String;

    return AppSettings(
      themeMode: AppSettings.themeModeFromString(themeValue),
      userName: userName,
      currencySymbol: CurrencyOptions.symbols.contains(currencySymbol)
          ? currencySymbol
          : CurrencyOptions.defaultSymbol,
    );
  }

  Future<void> saveThemeMode(ThemeMode themeMode) async {
    await _box.put(_themeKey, AppSettings.themeModeToString(themeMode));
  }

  Future<void> saveUserName(String userName) async {
    await _box.put(_userNameKey, userName.trim());
  }

  Future<void> saveCurrencySymbol(String currencySymbol) async {
    await _box.put(_currencySymbolKey, currencySymbol);
  }
}
