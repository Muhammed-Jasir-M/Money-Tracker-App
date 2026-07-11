part of 'settings_bloc.dart';

abstract class SettingsState extends Equatable {
  @override
  List<Object?> get props => [];
}

class SettingsInitial extends SettingsState {}

class SettingsLoading extends SettingsState {}

class SettingsLoaded extends SettingsState {
  SettingsLoaded(this.settings);

  final AppSettings settings;

  @override
  List<Object?> get props => [settings];
}

class SettingsError extends SettingsState {
  SettingsError(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}
