import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:money_tracker_app/core/constants/currencies.dart';

class AppSettings extends Equatable {
  const AppSettings({
    this.themeMode = ThemeMode.system,
    this.userName = '',
    this.currencySymbol = CurrencyOptions.defaultSymbol,
  });

  final ThemeMode themeMode;
  final String userName;
  final String currencySymbol;

  String get displayName => userName.trim().isEmpty ? 'there' : userName.trim();

  AppSettings copyWith({
    ThemeMode? themeMode,
    String? userName,
    String? currencySymbol,
  }) {
    return AppSettings(
      themeMode: themeMode ?? this.themeMode,
      userName: userName ?? this.userName,
      currencySymbol: currencySymbol ?? this.currencySymbol,
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
  List<Object?> get props => [themeMode, userName, currencySymbol];
}
