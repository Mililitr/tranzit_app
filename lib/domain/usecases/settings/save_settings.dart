import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:tranzit_app/core/errors/failures.dart';
import 'package:tranzit_app/core/usecases/usecase.dart';
import 'package:tranzit_app/domain/entities/settings.dart';
import 'package:tranzit_app/domain/repositories/settings_repository.dart';

/// Параметры для сохранения настроек
class SettingsParams extends Equatable {
  /// Настройки для сохранения
  final Settings settings;

  /// Создает экземпляр [SettingsParams]
  const SettingsParams({required this.settings});

  @override
  List<Object> get props => [settings];
}

/// Use case для сохранения настроек приложения
class SaveSettings implements UseCase<bool, SettingsParams> {
  final SettingsRepository repository;

  /// Создает экземпляр [SaveSettings]
  SaveSettings(this.repository);

  @override
  Future<Either<Failure, bool>> call(SettingsParams params) {
    return repository.saveSettings(params.settings);
  }
}