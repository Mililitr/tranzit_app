import 'package:dartz/dartz.dart';
import 'package:tranzit_app/core/errors/failures.dart';
import 'package:tranzit_app/domain/entities/settings.dart';

/// Интерфейс репозитория для работы с настройками
abstract class SettingsRepository {
  /// Получает настройки приложения
  /// 
  /// Возвращает [Either] с [Settings] в случае успеха
  /// или [Failure] в случае ошибки
  Future<Either<Failure, Settings>> getSettings();
  
  /// Сохраняет настройки приложения
  /// 
  /// Возвращает [Either] с [bool] в случае успеха
  /// или [Failure] в случае ошибки
  Future<Either<Failure, bool>> saveSettings(Settings settings);
  
  /// Обновляет тему приложения
  /// 
  /// Возвращает [Either] с [bool] в случае успеха
  /// или [Failure] в случае ошибки
  Future<Either<Failure, bool>> updateTheme(bool isDarkMode);
}