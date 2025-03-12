import 'package:dartz/dartz.dart';
import 'package:tranzit_app/core/errors/failures.dart';
import 'package:tranzit_app/core/usecases/usecase.dart';
import 'package:tranzit_app/domain/entities/settings.dart';
import 'package:tranzit_app/domain/repositories/settings_repository.dart';

/// Use case для получения настроек приложения
class GetSettings implements UseCase<Settings, NoParams> {
  final SettingsRepository repository;

  /// Создает экземпляр [GetSettings]
  GetSettings(this.repository);

  @override
  Future<Either<Failure, Settings>> call(NoParams params) {
    return repository.getSettings();
  }
}