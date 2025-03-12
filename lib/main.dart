import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tranzit_app/core/theme/app_theme.dart';
import 'package:tranzit_app/injection_container.dart' as di;
import 'package:tranzit_app/presentation/bloc/connection/connection_bloc.dart';
import 'package:tranzit_app/presentation/bloc/connection/connection_event.dart';
import 'package:tranzit_app/presentation/bloc/groups/groups_bloc.dart';
import 'package:tranzit_app/presentation/bloc/groups/groups_event.dart';
import 'package:tranzit_app/presentation/bloc/settings/settings_bloc.dart';
import 'package:tranzit_app/presentation/bloc/settings/settings_event.dart';
import 'package:tranzit_app/presentation/bloc/settings/settings_state.dart';
import 'package:tranzit_app/presentation/router/app_router.dart';

void main() async {
  // Перехват всех ошибок, которые не были обработаны в приложении
  runZonedGuarded(() async {
    WidgetsFlutterBinding.ensureInitialized();
    
    // Инициализация зависимостей
    await di.init();
    
    // Запуск приложения
    runApp(const MyApp());
  }, (error, stackTrace) {
    // Здесь можно добавить логирование ошибок
    debugPrint('❌ Необработанная ошибка: $error');
    debugPrint('Стек вызовов: $stackTrace');
    
    // В реальном приложении здесь можно отправлять ошибки в сервис аналитики
    // например, Firebase Crashlytics или Sentry
  });
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<GroupsBloc>(
          create: (_) => di.sl<GroupsBloc>()..add(const LoadGroups()),
        ),
        BlocProvider<SettingsBloc>(
          create: (_) => di.sl<SettingsBloc>()..add(const LoadSettings()),
        ),
        BlocProvider<ConnectionBloc>(
          create: (_) => di.sl<ConnectionBloc>()..add(const CheckConnectionEvent()),
        ),
      ],
      child: BlocBuilder<SettingsBloc, SettingsState>(
        builder: (context, state) {
          final isDarkMode = state is SettingsLoaded ? state.settings.isDarkMode : false;
          
          return MaterialApp.router(
            title: 'Tranzit App',
            // Исполь��уем наши кастомные темы
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: isDarkMode ? ThemeMode.dark : ThemeMode.light,
            routerConfig: AppRouter.router,
            debugShowCheckedModeBanner: false,
          );
        },
      ),
    );
  }
}