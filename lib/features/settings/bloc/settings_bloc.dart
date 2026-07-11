import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:money_tracker_app/data/models/settings/app_settings.dart';
import 'package:money_tracker_app/data/repositories/settings_repository.dart';

part 'settings_event.dart';
part 'settings_state.dart';

class SettingsBloc extends Bloc<SettingsEvent, SettingsState> {
  SettingsBloc({
    required SettingsRepository repository,
    AppSettings? initialSettings,
  })  : _repository = repository,
        super(
          initialSettings != null
              ? SettingsLoaded(initialSettings)
              : SettingsInitial(),
        ) {
    on<LoadSettings>(_onLoadSettings);
    on<UpdateThemeMode>(_onUpdateThemeMode);
    on<UpdateUserName>(_onUpdateUserName);
    on<UpdateCurrencySymbol>(_onUpdateCurrencySymbol);

    if (initialSettings == null) {
      add(LoadSettings());
    }
  }

  final SettingsRepository _repository;

  Future<void> _onLoadSettings(
    LoadSettings event,
    Emitter<SettingsState> emit,
  ) async {
    emit(SettingsLoading());
    try {
      final settings = await _repository.getSettings();
      emit(SettingsLoaded(settings));
    } catch (e) {
      emit(SettingsError(e.toString()));
    }
  }

  Future<void> _onUpdateThemeMode(
    UpdateThemeMode event,
    Emitter<SettingsState> emit,
  ) async {
    try {
      final settings = await _repository.updateThemeMode(event.themeMode);
      emit(SettingsLoaded(settings));
    } catch (e) {
      emit(SettingsError(e.toString()));
    }
  }

  Future<void> _onUpdateUserName(
    UpdateUserName event,
    Emitter<SettingsState> emit,
  ) async {
    try {
      final settings = await _repository.updateUserName(event.userName);
      emit(SettingsLoaded(settings));
    } catch (e) {
      emit(SettingsError(e.toString()));
    }
  }

  Future<void> _onUpdateCurrencySymbol(
    UpdateCurrencySymbol event,
    Emitter<SettingsState> emit,
  ) async {
    try {
      final settings =
          await _repository.updateCurrencySymbol(event.currencySymbol);
      emit(SettingsLoaded(settings));
    } catch (e) {
      emit(SettingsError(e.toString()));
    }
  }
}
