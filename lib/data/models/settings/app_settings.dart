import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

class AppSettings extends Equatable {
  const AppSettings({
    this.themeMode = ThemeMode.system,
    this.userName = '',
  });

  final ThemeMode themeMode;
  final String userName;

  String get displayName => userName.trim().isEmpty ? 'there' : userName.trim();

  AppSettings copyWith({
    ThemeMode? themeMode,
    String? userName,
  }) {
    return AppSettings(
      themeMode: themeMode ?? this.themeMode,
      userName: userName ?? this.userName,
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
  List<Object?> get props => [themeMode, userName];
}
