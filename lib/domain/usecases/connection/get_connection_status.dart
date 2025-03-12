import 'package:dartz/dartz.dart';
import 'package:tranzit_app/core/errors/failures.dart';
import 'package:tranzit_app/core/usecases/usecase.dart';
import 'package:tranzit_app/domain/entities/connection_status.dart';
import 'package:tranzit_app/domain/repositories/connection_repository.dart';

/// Use case для получения статуса подключения
class GetConnectionStatus implements UseCase<ConnectionStatus, NoParams> {
  final ConnectionRepository repository;

  /// Создает экземпляр [GetConnectionStatus]
  GetConnectionStatus(this.repository);

  @override
  Future<Either<Failure, ConnectionStatus>> call(NoParams params) {
    return repository.getConnectionStatus();
  }
}