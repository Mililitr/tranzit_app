import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:tranzit_app/core/errors/failures.dart';
import 'package:tranzit_app/core/usecases/usecase.dart';
import 'package:tranzit_app/domain/repositories/settings_repository.dart';

/// Параметры для обновления темы
class ThemeParams extends Equatable {
  /// Флаг темной темы
  final bool isDarkMode;

  /// Создает экземпляр [ThemeParams]
  const ThemeParams({required this.isDarkMode});

  @override
  List<Object> get props => [isDarkMode];
}

/// Use case для обновления темы приложения
class UpdateTheme implements UseCase<bool, ThemeParams> {
  final SettingsRepository repository;

  /// Создает экземпляр [UpdateTheme]
  UpdateTheme(this.repository);

  @override
  Future<Either<Failure, bool>> call(ThemeParams params) {
    return repository.updateTheme(params.isDarkMode);
  }
}