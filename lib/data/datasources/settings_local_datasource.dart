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
  static const _lockEnabledKey = 'lockEnabled';
  static const _useBiometricKey = 'useBiometric';
  static const _onboardingCompletedKey = 'onboardingCompleted';

  AppSettings getSettings() {
    final themeValue = _box.get(_themeKey, defaultValue: 'system') as String;
    final userName = _box.get(_userNameKey, defaultValue: '') as String;
    final currencySymbol =
        _box.get(_currencySymbolKey, defaultValue: CurrencyOptions.defaultSymbol)
            as String;
    final lockEnabled = _box.get(_lockEnabledKey, defaultValue: false) as bool;
    final useBiometric =
        _box.get(_useBiometricKey, defaultValue: false) as bool;

    return AppSettings(
      themeMode: AppSettings.themeModeFromString(themeValue),
      userName: userName,
      currencySymbol: CurrencyOptions.symbols.contains(currencySymbol)
          ? currencySymbol
          : CurrencyOptions.defaultSymbol,
      lockEnabled: lockEnabled,
      useBiometric: useBiometric,
      onboardingCompleted: _readOnboardingCompleted(),
    );
  }

  /// Missing flag: existing installs (non-empty box) skip onboarding;
  /// brand-new installs see it.
  bool _readOnboardingCompleted() {
    if (_box.containsKey(_onboardingCompletedKey)) {
      return _box.get(_onboardingCompletedKey) as bool;
    }
    return _box.isNotEmpty;
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

  Future<void> saveLockEnabled(bool lockEnabled) async {
    await _box.put(_lockEnabledKey, lockEnabled);
  }

  Future<void> saveUseBiometric(bool useBiometric) async {
    await _box.put(_useBiometricKey, useBiometric);
  }

  Future<void> saveOnboardingCompleted(bool completed) async {
    await _box.put(_onboardingCompletedKey, completed);
  }

  Future<void> saveAll(AppSettings settings) async {
    await saveThemeMode(settings.themeMode);
    await saveUserName(settings.userName);
    await saveCurrencySymbol(settings.currencySymbol);
    await saveLockEnabled(settings.lockEnabled);
    await saveUseBiometric(settings.useBiometric);
    await saveOnboardingCompleted(settings.onboardingCompleted);
  }
}
