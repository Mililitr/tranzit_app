import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:tranzit_app/presentation/pages/group_details_page.dart';
import 'package:tranzit_app/presentation/pages/groups_page.dart';
import 'package:tranzit_app/presentation/pages/settings_page.dart';
import 'package:tranzit_app/presentation/pages/splash_page.dart';

/// Маршрутизатор приложения
class AppRouter {
  /// Создает экземпляр маршрутизатора
  static final router = GoRouter(
    initialLocation: '/',
    debugLogDiagnostics: true,
    routes: [
      // Splash screen - начальный экран
      GoRoute(
        path: '/',
        builder: (context, state) => const SplashPage(),
      ),
      
      // Экран списка групп с вложенным маршрутом для деталей группы
      GoRoute(
        path: '/groups',
        builder: (context, state) => const GroupsPage(),
        routes: [
          GoRoute(
            path: ':id',
            builder: (context, state) {
              final groupId = state.pathParameters['id']!;
              return GroupDetailsPage(groupId: groupId);
            },
          ),
        ],
      ),
      
      // Экран настроек
      GoRoute(
        path: '/settings',
        builder: (context, state) => const SettingsPage(),
      ),
    ],
    
    // Обработка ошибок маршрутизации
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Text('Ошибка: ${state.error}'),
      ),
    ),
  );
}