import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:tranzit_app/core/errors/failures.dart';
import 'package:tranzit_app/core/usecases/usecase.dart';
import 'package:tranzit_app/domain/entities/settings.dart';
import 'package:tranzit_app/domain/usecases/settings/get_settings.dart';
import 'package:tranzit_app/domain/usecases/settings/save_settings.dart' as usecase;
import 'package:tranzit_app/domain/usecases/settings/update_theme.dart';
import 'package:tranzit_app/presentation/bloc/settings/settings_bloc.dart';
import 'package:tranzit_app/presentation/bloc/settings/settings_event.dart';
import 'package:tranzit_app/presentation/bloc/settings/settings_state.dart';
import 'package:bloc_test/bloc_test.dart';

import 'settings_bloc_test.mocks.dart';

@GenerateMocks([GetSettings, usecase.SaveSettings, UpdateTheme])
void main() {
  late MockGetSettings mockGetSettings;
  late MockSaveSettings mockSaveSettings;
  late MockUpdateTheme mockUpdateTheme;
  late SettingsBloc bloc;

  setUp(() {
    mockGetSettings = MockGetSettings();
    mockSaveSettings = MockSaveSettings();
    mockUpdateTheme = MockUpdateTheme();
    bloc = SettingsBloc(
      getSettings: mockGetSettings,
      saveSettings: mockSaveSettings,
      updateTheme: mockUpdateTheme,
    );
  });

  tearDown(() {
    bloc.close();
  });

  test('начальное состояние должно быть SettingsInitial', () {
    expect(bloc.state, equals(const SettingsInitial()));
  });

  group('LoadSettings', () {
    final tSettings = Settings(
      isDarkMode: true,
      notificationsEnabled: false,
      language: 'en',
      lastSyncTime: DateTime(2023, 1, 1),
    );

    blocTest<SettingsBloc, SettingsState>(
      'должен эмитировать [SettingsLoading, SettingsLoaded] при успешной загрузке настроек',
      build: () {
        when(mockGetSettings(any))
            .thenAnswer((_) async => Right(tSettings));
        return bloc;
      },
      act: (bloc) => bloc.add(const LoadSettings()),
      expect: () => [
        const SettingsLoading(),
        SettingsLoaded(settings: tSettings),
      ],
      verify: (_) {
        verify(mockGetSettings(NoParams()));
      },
    );

    blocTest<SettingsBloc, SettingsState>(
      'должен эмитировать [SettingsLoading, SettingsError] при ошибке заг��узки настроек',
      build: () {
        when(mockGetSettings(any))
            .thenAnswer((_) async => Left(CacheFailure(message: 'Ошибка загрузки')));
        return bloc;
      },
      act: (bloc) => bloc.add(const LoadSettings()),
      expect: () => [
        const SettingsLoading(),
        const SettingsError(message: 'Ошибка загрузки'),
      ],
      verify: (_) {
        verify(mockGetSettings(NoParams()));
      },
    );
  });

  group('SaveSettings', () {
    final tSettings = Settings(
      isDarkMode: true,
      notificationsEnabled: false,
      language: 'en',
      lastSyncTime: DateTime(2023, 1, 1),
    );

    blocTest<SettingsBloc, SettingsState>(
      'должен эмитировать [SettingsLoading, SettingsLoaded] при успешном сохранении настроек',
      build: () {
        when(mockSaveSettings(any))
            .thenAnswer((_) async => const Right(true));
        return bloc;
      },
      act: (bloc) => bloc.add(SaveSettings(settings: tSettings)),
      expect: () => [
        const SettingsLoading(),
        SettingsLoaded(settings: tSettings),
      ],
      verify: (_) {
        verify(mockSaveSettings(usecase.SettingsParams(settings: tSettings)));
      },
    );

    blocTest<SettingsBloc, SettingsState>(
      'должен эмитировать [SettingsLoading, SettingsError] при ошибке сохранения настроек',
      build: () {
        when(mockSaveSettings(any))
            .thenAnswer((_) async => Left(CacheFailure(message: 'Ошибка сохранения')));
        return bloc;
      },
      act: (bloc) => bloc.add(SaveSettings(settings: tSettings)),
      expect: () => [
        const SettingsLoading(),
        const SettingsError(message: 'Ошибка сохранения'),
      ],
      verify: (_) {
        verify(mockSaveSettings(usecase.SettingsParams(settings: tSettings)));
      },
    );
  });

  group('ToggleTheme', () {
    final tSettings = Settings(
      isDarkMode: false,
      notificationsEnabled: true,
      language: 'ru',
      lastSyncTime: DateTime(2023, 1, 1),
    );

    final tNewSettings = Settings(
      isDarkMode: true,
      notificationsEnabled: true,
      language: 'ru',
      lastSyncTime: DateTime(2023, 1, 1),
    );

    blocTest<SettingsBloc, SettingsState>(
      'должен эмитировать [SettingsLoaded] с обновленной темой при успешном обновлении',
      build: () {
        when(mockUpdateTheme(any))
            .thenAnswer((_) async => const Right(true));
        return bloc;
      },
      seed: () => SettingsLoaded(settings: tSettings),
      act: (bloc) => bloc.add(const ToggleTheme()),
      expect: () => [
        SettingsLoaded(settings: tNewSettings),
      ],
      verify: (_) {
        verify(mockUpdateTheme(const ThemeParams(isDarkMode: true)));
      },
    );

    blocTest<SettingsBloc, SettingsState>(
      'должен эмитировать [SettingsError] при ошибке обновления темы',
      build: () {
        when(mockUpdateTheme(any))
            .thenAnswer((_) async => Left(CacheFailure(message: 'Ошибка обновления темы')));
        return bloc;
      },
      seed: () => SettingsLoaded(settings: tSettings),
      act: (bloc) => bloc.add(const ToggleTheme()),
      expect: () => [
        const SettingsError(message: 'Ошибка обновления темы'),
      ],
      verify: (_) {
        verify(mockUpdateTheme(const ThemeParams(isDarkMode: true)));
      },
    );

    test('не должен эмитировать новые состояния, если текущее состояние не SettingsLoaded', () {
      // arrange
      when(mockUpdateTheme(any))
          .thenAnswer((_) async => const Right(true));
      
      // act
      bloc.add(const ToggleTheme());
      
      // assert
      expectLater(bloc.stream, emitsInOrder([]));
    });
  });
}