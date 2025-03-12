import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:tranzit_app/core/network/network_info.dart';
import 'package:tranzit_app/data/datasources/local/group_local_data_source.dart';
import 'package:tranzit_app/data/datasources/local/settings_local_data_source.dart';
import 'package:tranzit_app/data/datasources/remote/group_remote_data_source.dart';
import 'package:tranzit_app/data/models/group_model.dart';
import 'package:tranzit_app/data/models/settings_model.dart';
import 'package:tranzit_app/data/repositories/connection_repository_impl.dart';
import 'package:tranzit_app/data/repositories/group_repository_impl.dart';
import 'package:tranzit_app/data/repositories/settings_repository_impl.dart';
import 'package:tranzit_app/domain/repositories/connection_repository.dart';
import 'package:tranzit_app/domain/repositories/group_repository.dart';
import 'package:tranzit_app/domain/repositories/settings_repository.dart';
import 'package:tranzit_app/domain/usecases/connection/check_connection.dart';
import 'package:tranzit_app/domain/usecases/connection/get_connection_status.dart';
import 'package:tranzit_app/domain/usecases/connection/watch_connection_status.dart';
import 'package:tranzit_app/domain/usecases/group/get_group_by_id.dart';
import 'package:tranzit_app/domain/usecases/group/get_groups.dart';
import 'package:tranzit_app/domain/usecases/group/refresh_groups.dart';
import 'package:tranzit_app/domain/usecases/settings/get_settings.dart';
import 'package:tranzit_app/domain/usecases/settings/save_settings.dart';
import 'package:tranzit_app/domain/usecases/settings/update_theme.dart';
import 'package:tranzit_app/presentation/bloc/connection/connection_bloc.dart';
import 'package:tranzit_app/presentation/bloc/groups/groups_bloc.dart';
import 'package:tranzit_app/presentation/bloc/settings/settings_bloc.dart';

final sl = GetIt.instance;

/// Инициализирует зависимости приложения
Future<void> init() async {
  // Инициализация Hive
  await Hive.initFlutter();
  
  // Регистрация адаптеров
  Hive.registerAdapter(GroupModelHiveAdapter());
  Hive.registerAdapter(SettingsModelHiveAdapter());
  
  // Открытие боксов
  final groupsBox = await Hive.openBox<GroupModel>('groups_box');
  final metadataBox = await Hive.openBox('metadata_box');
  final settingsBox = await Hive.openBox<SettingsModel>('settings_box');

  // BLoCs
  sl.registerFactory(
    () => GroupsBloc(
      getGroups: sl(),
      refreshGroups: sl(),
      getGroupById: sl(),
    ),
  );
  
  sl.registerFactory(
    () => SettingsBloc(
      getSettings: sl(),
      saveSettings: sl(),
      updateTheme: sl(),
    ),
  );
  
  sl.registerFactory(
    () => ConnectionBloc(
      checkConnection: sl(),
      getConnectionStatus: sl(),
      watchConnectionStatus: sl(),
    ),
  );

  // Use cases
  sl.registerLazySingleton(() => GetGroups(sl()));
  sl.registerLazySingleton(() => RefreshGroups(sl()));
  sl.registerLazySingleton(() => GetGroupById(sl()));
  
  sl.registerLazySingleton(() => GetSettings(sl()));
  sl.registerLazySingleton(() => SaveSettings(sl()));
  sl.registerLazySingleton(() => UpdateTheme(sl()));
  
  sl.registerLazySingleton(() => CheckConnection(sl()));
  sl.registerLazySingleton(() => GetConnectionStatus(sl()));
  sl.registerLazySingleton(() => WatchConnectionStatus(sl()));

  // Repositories
  sl.registerLazySingleton<GroupRepository>(
    () => GroupRepositoryImpl(
      remoteDataSource: sl(),
      localDataSource: sl(),
      networkInfo: sl(),
    ),
  );
  
  sl.registerLazySingleton<SettingsRepository>(
    () => SettingsRepositoryImpl(
      localDataSource: sl(),
    ),
  );
  
  sl.registerLazySingleton<ConnectionRepository>(
    () => ConnectionRepositoryImpl(
      connectionChecker: sl(),
    ),
  );

  // Data sources
  sl.registerLazySingleton<GroupRemoteDataSource>(
    () => GroupRemoteDataSourceImpl(
      client: sl(),
    ),
  );
  
  sl.registerLazySingleton<GroupLocalDataSource>(
    () => GroupLocalDataSourceImpl(
      groupsBox: groupsBox,
      metadataBox: metadataBox,
    ),
  );
  
  sl.registerLazySingleton<SettingsLocalDataSource>(
    () => SettingsLocalDataSourceImpl(
      settingsBox: settingsBox,
    ),
  );

  // Core
  sl.registerLazySingleton<NetworkInfo>(
    () => NetworkInfoImpl(
      connectionChecker: sl(),
    ),
  );

  // External
  sl.registerLazySingleton(() => Dio(
    BaseOptions(
      baseUrl: 'https://api.wayhomeapp.org/',
      headers: {
        'Authorization': 'Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjE3MTkxNDM5MjEsImlkIjoiNTkiLCJuYW1lIjoiZmRhMmFmYmI3ZmRjMjE3NzU3MjQzODE4MmQ1MGVjZDMiLCJleHAiOjE3MTkxNDM5ODF9.1MU6c64soxKhagDtOqeIMbwuCH5Ng2wWTl6NxgeuJMs',
      },
    ),
  ));
  sl.registerLazySingleton(() => InternetConnectionChecker());
}