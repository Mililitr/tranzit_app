import 'package:dartz/dartz.dart';
import 'package:tranzit_app/core/errors/exceptions.dart';
import 'package:tranzit_app/core/errors/failures.dart';
import 'package:tranzit_app/data/datasources/local/settings_local_data_source.dart';
import 'package:tranzit_app/data/models/settings_model.dart';
import 'package:tranzit_app/domain/entities/settings.dart';
import 'package:tranzit_app/domain/repositories/settings_repository.dart';

/// Реализация [SettingsRepository]
class SettingsRepositoryImpl implements SettingsRepository {
  final SettingsLocalDataSource localDataSource;

  /// Создает экземпляр [SettingsRepositoryImpl]
  SettingsRepositoryImpl({
    required this.localDataSource,
  });

  @override
  Future<Either<Failure, Settings>> getSettings() async {
    try {
      final settingsModel = await localDataSource.getSettings();
      
      // Преобразуем SettingsModel в Settings
      final settings = Settings(
        isDarkMode: settingsModel.isDarkMode,
        notificationsEnabled: settingsModel.notificationsEnabled,
        language: settingsModel.language,
        lastSyncTime: settingsModel.lastSyncTime,
      );
      
      return Right(settings);
    } on CacheException catch (e) {
      return Left(CacheFailure(
        message: e.message,
        statusCode: e.statusCode,
      ));
    }
  }

  @override
  Future<Either<Failure, bool>> saveSettings(Settings settings) async {
    try {
      // Преобразуем Settings в SettingsModel
      final settingsModel = SettingsModel(
        isDarkMode: settings.isDarkMode,
        notificationsEnabled: settings.notificationsEnabled,
        language: settings.language,
        lastSyncTime: settings.lastSyncTime,
      );
      
      await localDataSource.saveSettings(settingsModel);
      return const Right(true);
    } on CacheException catch (e) {
      return Left(CacheFailure(
        message: e.message,
        statusCode: e.statusCode,
      ));
    }
  }

  @override
  Future<Either<Failure, bool>> updateTheme(bool isDarkMode) async {
    try {
      await localDataSource.updateTheme(isDarkMode);
      return const Right(true);
    } on CacheException catch (e) {
      return Left(CacheFailure(
        message: e.message,
        statusCode: e.statusCode,
      ));
    }
  }
}