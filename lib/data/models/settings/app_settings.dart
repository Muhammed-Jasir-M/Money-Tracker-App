import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

class AppSettings extends Equatable {
  const AppSettings({
    this.themeMode = ThemeMode.system,
  });

  final ThemeMode themeMode;

  AppSettings copyWith({ThemeMode? themeMode}) {
    return AppSettings(
      themeMode: themeMode ?? this.themeMode,
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
  List<Object?> get props => [themeMode];
}
