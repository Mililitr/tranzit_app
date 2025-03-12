import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:tranzit_app/core/errors/exceptions.dart';
import 'package:tranzit_app/core/errors/failures.dart';
import 'package:tranzit_app/core/network/network_info.dart';
import 'package:tranzit_app/data/datasources/local/group_local_data_source.dart';
import 'package:tranzit_app/data/datasources/remote/group_remote_data_source.dart';
import 'package:tranzit_app/data/models/group_model.dart';
import 'package:tranzit_app/data/repositories/group_repository_impl.dart';
import 'package:tranzit_app/domain/entities/group.dart';

import 'group_repository_impl_test.mocks.dart';

@GenerateMocks([
  GroupRemoteDataSource,
  GroupLocalDataSource,
  NetworkInfo,
])
void main() {
  late GroupRepositoryImpl repository;
  late MockGroupRemoteDataSource mockRemoteDataSource;
  late MockGroupLocalDataSource mockLocalDataSource;
  late MockNetworkInfo mockNetworkInfo;

  setUp(() {
    mockRemoteDataSource = MockGroupRemoteDataSource();
    mockLocalDataSource = MockGroupLocalDataSource();
    mockNetworkInfo = MockNetworkInfo();
    repository = GroupRepositoryImpl(
      remoteDataSource: mockRemoteDataSource,
      localDataSource: mockLocalDataSource,
      networkInfo: mockNetworkInfo,
    );
  });

  void runTestsOnline(Function body) {
    group('устройство онлайн', () {
      setUp(() {
        when(mockNetworkInfo.isConnected).thenAnswer((_) async => true);
      });

      body();
    });
  }

  void runTestsOffline(Function body) {
    group('устройство офлайн', () {
      setUp(() {
        when(mockNetworkInfo.isConnected).thenAnswer((_) async => false);
      });

      body();
    });
  }

  group('getGroups', () {
    final tGroupModelList = [
      GroupModel(
        id: '1',
        name: 'Test Group 1',
        description: 'Description 1',
        telegramLink: 'https://t.me/group1',
      ),
      GroupModel(
        id: '2',
        name: 'Test Group 2',
        description: 'Description 2',
        telegramLink: 'https://t.me/group2',
      ),
    ];

    final tGroupList = tGroupModelList;

    runTestsOnline(() {
      test(
        'должен возвращать список групп с сервера, когда вызов к удаленному источнику данных успешен',
        () async {
          // arrange
          when(mockRemoteDataSource.getGroups())
              .thenAnswer((_) async => tGroupModelList);

          // act
          final result = await repository.getGroups();

          // assert
          verify(mockRemoteDataSource.getGroups());
          verify(mockLocalDataSource.cacheGroups(tGroupModelList));
          expect(result, equals(Right(tGroupList)));
        },
      );

      test(
        'должен кэшировать данные локально, когда вызов к удаленному источнику данных успешен',
        () async {
          // arrange
          when(mockRemoteDataSource.getGroups())
              .thenAnswer((_) async => tGroupModelList);

          // act
          await repository.getGroups();

          // assert
          verify(mockRemoteDataSource.getGroups());
          verify(mockLocalDataSource.cacheGroups(tGroupModelList));
        },
      );

      test(
        'должен возвращать ServerFailure, когда вызов к удаленному источнику данных неуспешен',
        () async {
          // arrange
          when(mockRemoteDataSource.getGroups())
              .thenThrow(ServerException(message: 'Ошибка сервера'));

          when(mockLocalDataSource.getGroups())
              .thenThrow(CacheException(message: 'Нет кэшированных данных'));

          // act
          final result = await repository.getGroups();

          // assert
          verify(mockRemoteDataSource.getGroups());
          expect(
            result,
            equals(Left(ServerFailure(message: 'Ошибка сервера'))),
          );
        },
      );
    });

    runTestsOffline(() {
      test(
        'должен возвращать локально кэшированные данные, когда устройство офлайн',
        () async {
          // arrange
          when(mockLocalDataSource.getGroups())
              .thenAnswer((_) async => tGroupModelList);

          // act
          final result = await repository.getGroups();

          // assert
          verifyZeroInteractions(mockRemoteDataSource);
          verify(mockLocalDataSource.getGroups());
          expect(result, equals(Right(tGroupList)));
        },
      );

      test(
        'должен возвращать CacheFailure, когда нет кэшированных данных',
        () async {
          // arrange
          when(mockLocalDataSource.getGroups())
              .thenThrow(CacheException(message: 'Нет кэшированных данных'));

          // act
          final result = await repository.getGroups();

          // assert
          verifyZeroInteractions(mockRemoteDataSource);
          verify(mockLocalDataSource.getGroups());
          expect(
            result,
            equals(Left(CacheFailure(message: 'Нет кэшированных данных'))),
          );
        },
      );
    });
  });

  group('refreshGroups', () {
    final tGroupModelList = [
      GroupModel(
        id: '1',
        name: 'Test Group 1',
        description: 'Description 1',
        telegramLink: 'https://t.me/group1',
      ),
      GroupModel(
        id: '2',
        name: 'Test Group 2',
        description: 'Description 2',
        telegramLink: 'https://t.me/group2',
      ),
    ];

    final tGroupList = tGroupModelList;

    runTestsOnline(() {
      test(
        'должен возвращать список групп с сервера, когда вызов к удаленному источнику данных успешен',
        () async {
          // arrange
          when(mockRemoteDataSource.getGroups())
              .thenAnswer((_) async => tGroupModelList);

          // act
          final result = await repository.refreshGroups();

          // assert
          verify(mockRemoteDataSource.getGroups());
          verify(mockLocalDataSource.cacheGroups(tGroupModelList));
          expect(result, equals(Right(tGroupList)));
        },
      );

      test(
        'должен возвращать ServerFailure, когда вызов к удаленному источнику данных неуспешен',
        () async {
          // arrange
          when(mockRemoteDataSource.getGroups())
              .thenThrow(ServerException(message: 'Ошибка сервера'));

          // act
          final result = await repository.refreshGroups();

          // assert
          verify(mockRemoteDataSource.getGroups());
          expect(
            result,
            equals(Left(ServerFailure(message: 'Ошибка сервера'))),
          );
        },
      );
    });

    runTestsOffline(() {
      test(
        'должен возвращать NetworkFailure, когда устройство офлайн',
        () async {
          // act
          final result = await repository.refreshGroups();

          // assert
          verifyZeroInteractions(mockRemoteDataSource);
          expect(
            result,
            equals(const Left(NetworkFailure(message: 'Нет подключения к интернету'))),
          );
        },
      );
    });
  });

  group('getGroupById', () {
    final tGroupId = '1';
    final tGroupModelList = [
      GroupModel(
        id: '1',
        name: 'Test Group 1',
        description: 'Description 1',
        telegramLink: 'https://t.me/group1',
      ),
      GroupModel(
        id: '2',
        name: 'Test Group 2',
        description: 'Description 2',
        telegramLink: 'https://t.me/group2',
      ),
    ];

    final tGroupList = tGroupModelList;
    final tGroup = tGroupList[0];

    test(
      'должен возвращать группу по ID, когда она существует в списке',
      () async {
        // arrange
        when(mockNetworkInfo.isConnected).thenAnswer((_) async => true);
        when(mockRemoteDataSource.getGroups())
            .thenAnswer((_) async => tGroupModelList);

        // act
        final result = await repository.getGroupById(tGroupId);

        // assert
        expect(result, equals(Right(tGroup)));
      },
    );

    test(
      'должен возвращать CacheFailure, когда группа с указанным ID не найдена',
      () async {
        // arrange
        when(mockNetworkInfo.isConnected).thenAnswer((_) async => true);
        when(mockRemoteDataSource.getGroups())
            .thenAnswer((_) async => tGroupModelList);

        // act
        final result = await repository.getGroupById('999');

        // assert
        expect(
          result,
          equals(Left(CacheFailure(message: 'Группа с ID 999 не найдена'))),
        );
      },
    );
  });
}