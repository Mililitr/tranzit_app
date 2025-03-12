import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:tranzit_app/core/errors/failures.dart';
import 'package:tranzit_app/core/usecases/usecase.dart';
import 'package:tranzit_app/domain/entities/group.dart';
import 'package:tranzit_app/domain/repositories/group_repository.dart';

/// Параметры для получения группы по ID
class GroupParams extends Equatable {
  /// ID группы
  final String id;

  /// Создает экземпляр [GroupParams]
  const GroupParams({required this.id});

  @override
  List<Object> get props => [id];
}

/// Use case для получения группы по ID
class GetGroupById implements UseCase<Group, GroupParams> {
  final GroupRepository repository;

  /// Создает экземпляр [GetGroupById]
  GetGroupById(this.repository);

  @override
  Future<Either<Failure, Group>> call(GroupParams params) {
    return repository.getGroupById(params.id);
  }
}