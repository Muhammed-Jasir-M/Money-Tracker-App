part of 'settings_bloc.dart';

abstract class SettingsEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoadSettings extends SettingsEvent {}

class UpdateThemeMode extends SettingsEvent {
  UpdateThemeMode(this.themeMode);

  final ThemeMode themeMode;

  @override
  List<Object?> get props => [themeMode];
}

class UpdateUserName extends SettingsEvent {
  UpdateUserName(this.userName);

  final String userName;

  @override
  List<Object?> get props => [userName];
}

class UpdateCurrencySymbol extends SettingsEvent {
  UpdateCurrencySymbol(this.currencySymbol);

  final String currencySymbol;

  @override
  List<Object?> get props => [currencySymbol];
}
