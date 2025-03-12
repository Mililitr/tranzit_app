import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:tranzit_app/presentation/bloc/connection/connection_bloc.dart';
import 'package:tranzit_app/presentation/bloc/connection/connection_state.dart' as connection;
import 'package:tranzit_app/presentation/bloc/groups/groups_bloc.dart';
import 'package:tranzit_app/presentation/bloc/groups/groups_state.dart';

/// Страница загрузки приложения
class SplashPage extends StatefulWidget {
  /// Создает экземпляр [SplashPage]
  const SplashPage({Key? key}) : super(key: key);

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    
    // Переход на главный экран после загрузки данных
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        context.go('/groups');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Логотип или название приложения
            const Icon(
              Icons.group,
              size: 80,
              color: Colors.blue,
            ),
            const SizedBox(height: 16),
            const Text(
              'Tranzit App',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 32),
            
            // Индикатор загрузки
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            
            // Статус загрузки
            BlocBuilder<GroupsBloc, GroupsState>(
              builder: (context, state) {
                if (state is GroupsLoading) {
                  return const Text('Загрузка групп...');
                } else if (state is GroupsError) {
                  return Text('Ошибка: ${state.message}');
                } else if (state is GroupsLoaded) {
                  return const Text('Группы загружены!');
                }
                return const Text('Инициализация...');
              },
            ),
            const SizedBox(height: 8),
            
            // Статус подключения
            BlocBuilder<ConnectionBloc, connection.ConnectionState>(
              builder: (context, state) {
                if (state is connection.ConnectionInfo) {
                  return Text(
                    state.status.hasInternet
                        ? 'Подключено к интернету'
                        : 'Нет подключения к интернету',
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ],
        ),
      ),
    );
  }
}