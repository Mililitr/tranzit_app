import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tranzit_app/domain/entities/connection_status.dart';
import 'package:tranzit_app/presentation/bloc/connection/connection_state.dart' as connection;
import 'package:tranzit_app/presentation/bloc/connection/connection_bloc.dart';

/// Виджет для отображения статуса подключения
class ConnectionStatusWidget extends StatelessWidget {
  /// Создает экземпляр [ConnectionStatusWidget]
  const ConnectionStatusWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ConnectionBloc, connection.ConnectionState>(
      builder: (context, state) {
        if (state is connection.ConnectionInfo) {
          final status = state.status;
          
          // Если есть подключение, не показываем виджет
          if (status.hasInternet) {
            return const SizedBox.shrink();
          }
          
          // Показываем предупреждение, если нет подключения
          return Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            color: Colors.orange.shade100,
            child: Row(
              children: [
                const Icon(
                  Icons.wifi_off,
                  color: Colors.orange,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Нет подключения к интернету. Данные могут быть устаревшими.',
                    style: TextStyle(
                      color: Colors.orange.shade900,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          );
        }
        
        return const SizedBox.shrink();
      },
    );
  }
}