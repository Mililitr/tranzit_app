import 'package:equatable/equatable.dart';
import 'package:tranzit_app/domain/entities/settings.dart';

/// События для [SettingsBloc]
abstract class SettingsEvent extends Equatable {
  const SettingsEvent();

  @override
  List<Object?> get props => [];
}

/// Событие для загрузки настроек
class LoadSettings extends SettingsEvent {
  const LoadSettings();
}

/// Событие для сохранения настроек
class SaveSettings extends SettingsEvent {
  /// Настройки для сохранения
  final Settings settings;

  /// Создает экземпляр [SaveSettings]
  const SaveSettings({required this.settings});

  @override
  List<Object?> get props => [settings];
}

/// Событие для изменения темы
class ToggleTheme extends SettingsEvent {
  const ToggleTheme();
}