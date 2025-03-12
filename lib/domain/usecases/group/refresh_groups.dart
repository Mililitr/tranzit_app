import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:tranzit_app/core/errors/failures.dart';
import 'package:tranzit_app/core/usecases/usecase.dart';
import 'package:tranzit_app/domain/entities/group.dart';
import 'package:tranzit_app/domain/repositories/group_repository.dart';

/// Use case для обновления списка групп с сервера
class RefreshGroups implements UseCase<List<Group>, NoParams> {
  final GroupRepository repository;

  /// Создает экземпляр [RefreshGroups]
  RefreshGroups(this.repository);

  @override
  Future<Either<Failure, List<Group>>> call(NoParams params) {
    return repository.refreshGroups();
  }
}