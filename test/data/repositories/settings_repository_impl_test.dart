import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:tranzit_app/core/errors/exceptions.dart';
import 'package:tranzit_app/core/errors/failures.dart';
import 'package:tranzit_app/data/datasources/local/settings_local_data_source.dart';
import 'package:tranzit_app/data/models/settings_model.dart';
import 'package:tranzit_app/data/repositories/settings_repository_impl.dart';
import 'package:tranzit_app/domain/entities/settings.dart';

import 'settings_repository_impl_test.mocks.dart';

@GenerateMocks([SettingsLocalDataSource])
void main() {
  late SettingsRepositoryImpl repository;
  late MockSettingsLocalDataSource mockLocalDataSource;

  setUp(() {
    mockLocalDataSource = MockSettingsLocalDataSource();
    repository = SettingsRepositoryImpl(
      localDataSource: mockLocalDataSource,
    );
  });

  group('getSettings', () {
    final tSettingsModel = SettingsModel(
      isDarkMode: true,
      notificationsEnabled: false,
      language: 'en',
      lastSyncTime: DateTime(2023, 1, 1),
    );

    final tSettings = Settings(
      isDarkMode: true,
      notificationsEnabled: false,
      language: 'en',
      lastSyncTime: DateTime(2023, 1, 1),
    );

    test(
      'должен возвращать Settings, когда вызов к локальному источнику данных успешен',
      () async {
        // arrange
        when(mockLocalDataSource.getSettings())
            .thenAnswer((_) async => tSettingsModel);

        // act
        final result = await repository.getSettings();

        // assert
        verify(mockLocalDataSource.getSettings());
        expect(result, equals(Right(tSettings)));
      },
    );

    test(
      'должен возвращать CacheFailure, когда вызов к локальному источнику данных неуспешен',
      () async {
        // arrange
        when(mockLocalDataSource.getSettings())
            .thenThrow(CacheException(message: 'Ошибка кэша'));

        // act
        final result = await repository.getSettings();

        // assert
        verify(mockLocalDataSource.getSettings());
        expect(
          result,
          equals(Left(CacheFailure(message: 'Ошибка кэша'))),
        );
      },
    );
  });

  group('saveSettings', () {
    final tSettings = Settings(
      isDarkMode: true,
      notificationsEnabled: false,
      language: 'en',
      lastSyncTime: DateTime(2023, 1, 1),
    );

    final tSettingsModel = SettingsModel(
      isDarkMode: true,
      notificationsEnabled: false,
      language: 'en',
      lastSyncTime: DateTime(2023, 1, 1),
    );

    test(
      'должен вызывать метод saveSettings локального источника данных с правильными параметрами',
      () async {
        // arrange
        when(mockLocalDataSource.saveSettings(any))
            .thenAnswer((_) async => {});

        // act
        await repository.saveSettings(tSettings);

        // assert
        verify(mockLocalDataSource.saveSettings(tSettingsModel));
      },
    );

    test(
      'должен возвращать true, когда вызов к локальному источнику данных успешен',
      () async {
        // arrange
        when(mockLocalDataSource.saveSettings(any))
            .thenAnswer((_) async => {});

        // act
        final result = await repository.saveSettings(tSettings);

        // assert
        expect(result, equals(const Right(true)));
      },
    );

    test(
      'должен возвращать CacheFailure, когда вызов к локальному источнику данных неуспешен',
      () async {
        // arrange
        when(mockLocalDataSource.saveSettings(any))
            .thenThrow(CacheException(message: 'Ошибка сохранения'));

        // act
        final result = await repository.saveSettings(tSettings);

        // assert
        expect(
          result,
          equals(Left(CacheFailure(message: 'Ошибка сохранения'))),
        );
      },
    );
  });

  group('updateTheme', () {
    const tIsDarkMode = true;

    test(
      'должен вызывать метод updateTheme локального источника данных с правильными параметрами',
      () async {
        // arrange
        when(mockLocalDataSource.updateTheme(any))
            .thenAnswer((_) async => {});

        // act
        await repository.updateTheme(tIsDarkMode);

        // assert
        verify(mockLocalDataSource.updateTheme(tIsDarkMode));
      },
    );

    test(
      'должен возвращать true, когда вызов к локальному источнику данных успешен',
      () async {
        // arrange
        when(mockLocalDataSource.updateTheme(any))
            .thenAnswer((_) async => {});

        // act
        final result = await repository.updateTheme(tIsDarkMode);

        // assert
        expect(result, equals(const Right(true)));
      },
    );

    test(
      'должен возвращать CacheFailure, когда вызов к локальному источнику данных неуспешен',
      () async {
        // arrange
        when(mockLocalDataSource.updateTheme(any))
            .thenThrow(CacheException(message: 'Ошибка обновления темы'));

        // act
        final result = await repository.updateTheme(tIsDarkMode);

        // assert
        expect(
          result,
          equals(Left(CacheFailure(message: 'Ошибка обновления темы'))),
        );
      },
    );
  });
}