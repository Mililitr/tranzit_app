import 'package:equatable/equatable.dart';
import 'package:tranzit_app/domain/entities/settings.dart';

/// Состояния для [SettingsBloc]
abstract class SettingsState extends Equatable {
  const SettingsState();

  @override
  List<Object?> get props => [];
}

/// Начальное состояние
class SettingsInitial extends SettingsState {
  const SettingsInitial();
}

/// Состояние загрузки
class SettingsLoading extends SettingsState {
  const SettingsLoading();
}

/// Состояние успешной загрузки
class SettingsLoaded extends SettingsState {
  /// Настройки приложения
  final Settings settings;

  /// Создает экземпляр [SettingsLoaded]
  const SettingsLoaded({required this.settings});

  @override
  List<Object?> get props => [settings];

  /// Создает копию с новыми значениями
  SettingsLoaded copyWith({
    Settings? settings,
  }) {
    return SettingsLoaded(
      settings: settings ?? this.settings,
    );
  }
}

/// Состояние ошибки
class SettingsError extends SettingsState {
  /// Сообщение об ошибке
  final String message;

  /// Создает экземпляр [SettingsError]
  const SettingsError({required this.message});

  @override
  List<Object?> get props => [message];
}