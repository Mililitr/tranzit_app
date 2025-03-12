import 'package:dartz/dartz.dart';
import 'package:tranzit_app/core/errors/failures.dart';
import 'package:tranzit_app/domain/entities/group.dart';

/// Интерфейс репозитория для работы с группами
abstract class GroupRepository {
  /// Получает список всех групп
  /// 
  /// Возвращает [Either] с [List<Group>] в случае успеха
  /// или [Failure] в случае ошибки
  Future<Either<Failure, List<Group>>> getGroups();
  
  /// Обновляет список групп с сервера
  /// 
  /// Возвращает [Either] с [List<Group>] в случае успеха
  /// или [Failure] в случае ошибки
  Future<Either<Failure, List<Group>>> refreshGroups();
  
  /// Получает группу по идентификатору
  /// 
  /// Возвращает [Either] с [Group] в случае успеха
  /// или [Failure] в случае ошибки
  Future<Either<Failure, Group>> getGroupById(String id);
}