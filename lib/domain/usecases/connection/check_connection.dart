import 'package:dartz/dartz.dart';
import 'package:tranzit_app/core/errors/failures.dart';
import 'package:tranzit_app/core/usecases/usecase.dart';
import 'package:tranzit_app/domain/repositories/connection_repository.dart';

/// Use case для проверки наличия интернет-соединения
class CheckConnection implements UseCase<bool, NoParams> {
  final ConnectionRepository repository;

  /// Создает экземпляр [CheckConnection]
  CheckConnection(this.repository);

  @override
  Future<Either<Failure, bool>> call(NoParams params) {
    return repository.hasInternetConnection();
  }
}