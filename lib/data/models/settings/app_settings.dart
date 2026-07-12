import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:money_tracker_app/core/constants/currencies.dart';

class AppSettings extends Equatable {
  const AppSettings({
    this.themeMode = ThemeMode.system,
    this.userName = '',
    this.currencySymbol = CurrencyOptions.defaultSymbol,
    this.lockEnabled = false,
    this.useBiometric = false,
    this.onboardingCompleted = false,
  });

  final ThemeMode themeMode;
  final String userName;
  final String currencySymbol;
  final bool lockEnabled;
  final bool useBiometric;
  final bool onboardingCompleted;

  String get displayName => userName.trim().isEmpty ? 'there' : userName.trim();

  AppSettings copyWith({
    ThemeMode? themeMode,
    String? userName,
    String? currencySymbol,
    bool? lockEnabled,
    bool? useBiometric,
    bool? onboardingCompleted,
  }) {
    return AppSettings(
      themeMode: themeMode ?? this.themeMode,
      userName: userName ?? this.userName,
      currencySymbol: currencySymbol ?? this.currencySymbol,
      lockEnabled: lockEnabled ?? this.lockEnabled,
      useBiometric: useBiometric ?? this.useBiometric,
      onboardingCompleted: onboardingCompleted ?? this.onboardingCompleted,
    );
  }

  static ThemeMode themeModeFromString(String value) {
    return switch (value) {
      'light' => ThemeMode.light,
      'dark' => ThemeMode.dark,
      _ => ThemeMode.system,
    };
  }

  static String themeModeToString(ThemeMode mode) {
    return switch (mode) {
      ThemeMode.light => 'light',
      ThemeMode.dark => 'dark',
      ThemeMode.system => 'system',
    };
  }

  @override
  List<Object?> get props => [
        themeMode,
        userName,
        currencySymbol,
        lockEnabled,
        useBiometric,
        onboardingCompleted,
      ];
}
