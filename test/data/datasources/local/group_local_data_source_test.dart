import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:tranzit_app/core/errors/exceptions.dart';
import 'package:tranzit_app/data/datasources/local/group_local_data_source.dart';
import 'package:tranzit_app/data/models/group_model.dart';

import 'group_local_data_source_test.mocks.dart';

@GenerateMocks([Box, HiveInterface])
void main() {
  late GroupLocalDataSourceImpl dataSource;
  late MockBox<GroupModel> mockGroupsBox;
  late MockBox<dynamic> mockMetadataBox;

  setUp(() {
    mockGroupsBox = MockBox<GroupModel>();
    mockMetadataBox = MockBox<dynamic>();
    dataSource = GroupLocalDataSourceImpl(
      groupsBox: mockGroupsBox,
      metadataBox: mockMetadataBox,
    );
  });

  group('getGroups', () {
    final tGroupModels = [
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

    test(
      'должен возвращать список GroupModel из кэша',
      () async {
        // arrange
        when(mockGroupsBox.values).thenReturn(tGroupModels);

        // act
        final result = await dataSource.getGroups();

        // assert
        verify(mockGroupsBox.values);
        expect(result, equals(tGroupModels));
      },
    );

    test(
      'должен выбрасывать CacheException, если кэш пуст',
      () async {
        // arrange
        when(mockGroupsBox.values).thenReturn([]);

        // act
        final call = dataSource.getGroups;

        // assert
        expect(
          () => call(),
          throwsA(isA<CacheException>().having(
            (e) => e.message,
            'message',
            'No cached groups found',
          )),
        );
        verify(mockGroupsBox.values);
      },
    );
  });

  group('cacheGroups', () {
    final tGroupModels = [
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

    test(
      'должен вызывать методы clear и put для сохранения групп в кэш',
      () async {
        // arrange
        when(mockGroupsBox.clear()).thenAnswer((_) async => 0);
        when(mockGroupsBox.put(any, any)).thenAnswer((_) async => {});
        when(mockMetadataBox.put(any, any)).thenAnswer((_) async => {});

        // act
        await dataSource.cacheGroups(tGroupModels);

        // assert
        verify(mockGroupsBox.clear());
        verify(mockGroupsBox.put(0, tGroupModels[0]));
        verify(mockGroupsBox.put(1, tGroupModels[1]));
        verify(mockMetadataBox.put(lastUpdateKey, any));
      },
    );

    test(
      'должен выбрасывать CacheException при ошибке сохранения в кэш',
      () async {
        // arrange
        when(mockGroupsBox.clear()).thenThrow(Exception('Cache error'));

        // act
        final call = dataSource.cacheGroups;

        // assert
        expect(
          () => call(tGroupModels),
          throwsA(isA<CacheException>().having(
            (e) => e.message,
            'message',
            contains('Failed to cache groups'),
          )),
        );
        verify(mockGroupsBox.clear());
      },
    );
  });

  group('getLastUpdateTime', () {
    final tTimestamp = DateTime.now().millisecondsSinceEpoch;
    final tDateTime = DateTime.fromMillisecondsSinceEpoch(tTimestamp);

    test(
      'должен возвращать DateTime из кэша',
      () async {
        // arrange
        when(mockMetadataBox.get(lastUpdateKey)).thenReturn(tTimestamp);

        // act
        final result = await dataSource.getLastUpdateTime();

        // assert
        verify(mockMetadataBox.get(lastUpdateKey));
        expect(result, equals(tDateTime));
      },
    );

    test(
      'должен возвращать null, если в кэше нет времени последнего обновления',
      () async {
        // arrange
        when(mockMetadataBox.get(lastUpdateKey)).thenReturn(null);

        // act
        final result = await dataSource.getLastUpdateTime();

        // assert
        verify(mockMetadataBox.get(lastUpdateKey));
        expect(result, isNull);
      },
    );

    test(
      'должен выбрасывать CacheException при ошибке получения времени из кэша',
      () async {
        // arrange
        when(mockMetadataBox.get(lastUpdateKey)).thenThrow(Exception('Cache error'));

        // act
        final call = dataSource.getLastUpdateTime;

        // assert
        expect(
          () => call(),
          throwsA(isA<CacheException>().having(
            (e) => e.message,
            'message',
            contains('Failed to get last update time'),
          )),
        );
        verify(mockMetadataBox.get(lastUpdateKey));
      },
    );
  });

  group('clearCache', () {
    test(
      'должен вызывать методы clear и delete для очистки кэша',
      () async {
        // arrange
        when(mockGroupsBox.clear()).thenAnswer((_) async => 0);
        when(mockMetadataBox.delete(lastUpdateKey)).thenAnswer((_) async => true);

        // act
        await dataSource.clearCache();

        // assert
        verify(mockGroupsBox.clear());
        verify(mockMetadataBox.delete(lastUpdateKey));
      },
    );

    test(
      'должен выбрасывать CacheException при ошибке очистки кэша',
      () async {
        // arrange
        when(mockGroupsBox.clear()).thenThrow(Exception('Cache error'));

        // act
        final call = dataSource.clearCache;

        // assert
        expect(
          () => call(),
          throwsA(isA<CacheException>().having(
            (e) => e.message,
            'message',
            contains('Failed to clear cache'),
          )),
        );
        verify(mockGroupsBox.clear());
      },
    );
  });
}