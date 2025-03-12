import 'package:equatable/equatable.dart';

/// Сущность настроек приложения
class Settings extends Equatable {
  /// Флаг темной темы
  final bool isDarkMode;
  
  /// Флаг включения уведомлений
  final bool notificationsEnabled;
  
  /// Язык приложения
  final String language;
  
  /// Время последней синхронизации
  final DateTime? lastSyncTime;

  /// Создает экземпляр [Settings]
  const Settings({
    this.isDarkMode = false,
    this.notificationsEnabled = true,
    this.language = 'ru',
    this.lastSyncTime,
  });

  @override
  List<Object?> get props => [
    isDarkMode,
    notificationsEnabled,
    language,
    lastSyncTime,
  ];

  /// Создает копию с новыми значениями
  Settings copyWith({
    bool? isDarkMode,
    bool? notificationsEnabled,
    String? language,
    DateTime? lastSyncTime,
  }) {
    return Settings(
      isDarkMode: isDarkMode ?? this.isDarkMode,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      language: language ?? this.language,
      lastSyncTime: lastSyncTime ?? this.lastSyncTime,
    );
  }
}