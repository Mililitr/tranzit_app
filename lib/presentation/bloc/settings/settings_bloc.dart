import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tranzit_app/core/usecases/usecase.dart';
import 'package:tranzit_app/domain/entities/settings.dart';
import 'package:tranzit_app/domain/usecases/settings/get_settings.dart';
import 'package:tranzit_app/domain/usecases/settings/save_settings.dart' as usecase;
import 'package:tranzit_app/domain/usecases/settings/update_theme.dart';
import 'package:tranzit_app/presentation/bloc/settings/settings_event.dart';
import 'package:tranzit_app/presentation/bloc/settings/settings_state.dart';

/// Блок для управления настройками
class SettingsBloc extends Bloc<SettingsEvent, SettingsState> {
  final GetSettings _getSettings;
  final usecase.SaveSettings _saveSettings;
  final UpdateTheme _updateTheme;

  /// Создает экземпляр [SettingsBloc]
  SettingsBloc({
    required GetSettings getSettings,
    required usecase.SaveSettings saveSettings,
    required UpdateTheme updateTheme,
  })  : _getSettings = getSettings,
        _saveSettings = saveSettings,
        _updateTheme = updateTheme,
        super(const SettingsInitial()) {
    on<LoadSettings>(_onLoadSettings);
    on<SaveSettings>(_onSaveSettings);
    on<ToggleTheme>(_onToggleTheme);
  }

  /// Обрабатывает событие [LoadSettings]
  Future<void> _onLoadSettings(
    LoadSettings event,
    Emitter<SettingsState> emit,
  ) async {
    emit(const SettingsLoading());
    final result = await _getSettings(NoParams());
    result.fold(
      (failure) => emit(SettingsError(message: failure.message)),
      (settings) => emit(SettingsLoaded(settings: settings)),
    );
  }

  /// Обрабатывает событие [SaveSettings]
  Future<void> _onSaveSettings(
    SaveSettings event,
    Emitter<SettingsState> emit,
  ) async {
    emit(const SettingsLoading());
    final result = await _saveSettings(usecase.SettingsParams(settings: event.settings));
    result.fold(
      (failure) => emit(SettingsError(message: failure.message)),
      (_) => emit(SettingsLoaded(settings: event.settings)),
    );
  }

  /// Обрабатывает событие [ToggleTheme]
  Future<void> _onToggleTheme(
    ToggleTheme event,
    Emitter<SettingsState> emit,
  ) async {
    if (state is SettingsLoaded) {
      final currentState = state as SettingsLoaded;
      final currentSettings = currentState.settings;
      final newIsDarkMode = !currentSettings.isDarkMode;
      
      // Обновляем тему
      final result = await _updateTheme(ThemeParams(isDarkMode: newIsDarkMode));
      
      result.fold(
        (failure) => emit(SettingsError(message: failure.message)),
        (_) {
          // Создаем новые настройки с обновленной темой
          final newSettings = Settings(
            isDarkMode: newIsDarkMode,
            notificationsEnabled: currentSettings.notificationsEnabled,
            language: currentSettings.language,
            lastSyncTime: currentSettings.lastSyncTime,
          );
          
          emit(SettingsLoaded(settings: newSettings));
        },
      );
    }
  }
}