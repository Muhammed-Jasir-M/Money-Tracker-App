import 'package:flutter/material.dart';
import 'package:money_tracker_app/core/security/lock_service.dart';
import 'package:money_tracker_app/data/datasources/settings_local_datasource.dart';
import 'package:money_tracker_app/data/models/settings/app_settings.dart';

class SettingsRepository {
  SettingsRepository({
    required SettingsLocalDatasource datasource,
    LockService? lockService,
  })  : _datasource = datasource,
        _lockService = lockService ?? LockService();

  final SettingsLocalDatasource _datasource;
  final LockService _lockService;

  LockService get lockService => _lockService;

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

  Future<AppSettings> updateLockEnabled(bool lockEnabled) async {
    await _datasource.saveLockEnabled(lockEnabled);
    if (!lockEnabled) {
      await _datasource.saveUseBiometric(false);
    }
    return _datasource.getSettings();
  }

  Future<AppSettings> updateUseBiometric(bool useBiometric) async {
    await _datasource.saveUseBiometric(useBiometric);
    return _datasource.getSettings();
  }

  Future<AppSettings> completeOnboarding({
    required String userName,
    required String currencySymbol,
  }) async {
    await _datasource.saveUserName(userName);
    await _datasource.saveCurrencySymbol(currencySymbol);
    await _datasource.saveOnboardingCompleted(true);
    return _datasource.getSettings();
  }

  Future<void> setPin(String pin) => _lockService.setPin(pin);

  Future<bool> verifyPin(String pin) => _lockService.verifyPin(pin);

  Future<bool> hasPin() => _lockService.hasPin();

  Future<void> clearPin() => _lockService.clearPin();

  Future<AppSettings> restoreSettings(AppSettings settings) async {
    await _datasource.saveAll(settings);
    var restored = _datasource.getSettings();
    if (restored.lockEnabled && !await _lockService.hasPin()) {
      restored = await updateLockEnabled(false);
    }
    return restored;
  }

  Future<AppSettings> resetToDefaults() async {
    const defaults = AppSettings();
    await _datasource.saveAll(defaults);
    await _lockService.clearPin();
    return defaults;
  }
}
