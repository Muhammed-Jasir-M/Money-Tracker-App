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

class UpdateLockEnabled extends SettingsEvent {
  UpdateLockEnabled(this.lockEnabled);

  final bool lockEnabled;

  @override
  List<Object?> get props => [lockEnabled];
}

class UpdateUseBiometric extends SettingsEvent {
  UpdateUseBiometric(this.useBiometric);

  final bool useBiometric;

  @override
  List<Object?> get props => [useBiometric];
}

class CompleteOnboarding extends SettingsEvent {
  CompleteOnboarding({
    required this.userName,
    required this.currencySymbol,
  });

  final String userName;
  final String currencySymbol;

  @override
  List<Object?> get props => [userName, currencySymbol];
}
