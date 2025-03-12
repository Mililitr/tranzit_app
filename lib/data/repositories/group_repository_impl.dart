import 'package:dartz/dartz.dart';
import 'package:tranzit_app/core/errors/exceptions.dart';
import 'package:tranzit_app/core/errors/failures.dart';
import 'package:tranzit_app/core/network/network_info.dart';
import 'package:tranzit_app/data/datasources/local/group_local_data_source.dart';
import 'package:tranzit_app/data/datasources/remote/group_remote_data_source.dart';
import 'package:tranzit_app/data/models/group_model.dart';
import 'package:tranzit_app/domain/entities/group.dart';
import 'package:tranzit_app/domain/repositories/group_repository.dart';

/// Реализация [GroupRepository]
class GroupRepositoryImpl implements GroupRepository {
  final GroupRemoteDataSource remoteDataSource;
  final GroupLocalDataSource localDataSource;
  final NetworkInfo networkInfo;

  /// Создает экземпляр [GroupRepositoryImpl]
  GroupRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.networkInfo,
  });

  /// Преобразует список GroupModel в список Group
  List<Group> _convertToGroups(List<GroupModel> models) {
    return models.map<Group>((model) => Group(
      id: model.id,
      name: model.name,
      description: model.description,
      telegramLink: model.telegramLink,
      membersCount: model.membersCount,
      createdAt: model.createdAt,
      updatedAt: model.updatedAt,
      additionalData: model.additionalData,
    )).toList();
  }

  @override
  Future<Either<Failure, List<Group>>> getGroups() async {
    try {
      // Проверяем наличие интернет-соединения
      final isConnected = await networkInfo.isConnected;
      
      if (isConnected) {
        try {
          // Если есть интернет, получаем данные с сервера
          final remoteGroups = await remoteDataSource.getGroups();
          
          // Сохраняем данные в локальное хранилище
          await localDataSource.cacheGroups(remoteGroups);
          
          // Преобразуем GroupModel в Group
          return Right(_convertToGroups(remoteGroups));
        } on ServerException catch (e) {
          // Если произошла ошибка сервера, пытаемся получить данные из кэша
          try {
            final localGroups = await localDataSource.getGroups();
            return Right(_convertToGroups(localGroups));
          } on CacheException catch (e) {
            return Left(CacheFailure(
              message: e.message,
              statusCode: e.statusCode,
            ));
          }
        }
      } else {
        // Если нет интернета, получаем данные из кэша
        try {
          final localGroups = await localDataSource.getGroups();
          return Right(_convertToGroups(localGroups));
        } on CacheException catch (e) {
          return Left(CacheFailure(
            message: e.message,
            statusCode: e.statusCode,
          ));
        }
      }
    } on Exception catch (e) {
      return Left(ServerFailure(
        message: e.toString(),
      ));
    }
  }

  @override
  Future<Either<Failure, List<Group>>> refreshGroups() async {
    try {
      // Проверяем наличие интернет-соединения
      final isConnected = await networkInfo.isConnected;
      
      if (isConnected) {
        // Получаем данные с сервера
        final remoteGroups = await remoteDataSource.getGroups();
        
        // Сохраняем данные в локальное хранилище
        await localDataSource.cacheGroups(remoteGroups);
        
        // Преобразуем GroupModel в Group
        return Right(_convertToGroups(remoteGroups));
      } else {
        return const Left(NetworkFailure(
          message: 'Нет подключения к интернету',
        ));
      }
    } on ServerException catch (e) {
      return Left(ServerFailure(
        message: e.message,
        statusCode: e.statusCode,
      ));
    } on CacheException catch (e) {
      return Left(CacheFailure(
        message: e.message,
        statusCode: e.statusCode,
      ));
    }
  }

  @override
  Future<Either<Failure, Group>> getGroupById(String id) async {
    try {
      // Получаем все группы
      final groupsResult = await getGroups();
      
      return groupsResult.fold(
        (failure) => Left(failure),
        (groups) {
          // Ищем группу по ID
          final group = groups.firstWhere(
            (group) => group.id == id,
            orElse: () => throw CacheException(
              message: 'Группа с ID $id не найдена',
            ),
          );
          
          return Right(group);
        },
      );
    } on CacheException catch (e) {
      return Left(CacheFailure(
        message: e.message,
        statusCode: e.statusCode,
      ));
    } on Exception catch (e) {
      return Left(ServerFailure(
        message: e.toString(),
      ));
    }
  }
}