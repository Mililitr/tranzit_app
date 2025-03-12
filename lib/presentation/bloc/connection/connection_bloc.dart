import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tranzit_app/core/usecases/usecase.dart';
import 'package:tranzit_app/domain/entities/connection_status.dart';
import 'package:tranzit_app/domain/usecases/connection/check_connection.dart';
import 'package:tranzit_app/domain/usecases/connection/get_connection_status.dart';
import 'package:tranzit_app/domain/usecases/connection/watch_connection_status.dart';
import 'package:tranzit_app/presentation/bloc/connection/connection_event.dart';
import 'package:tranzit_app/presentation/bloc/connection/connection_state.dart';

/// Блок для управления состоянием подключения
class ConnectionBloc extends Bloc<ConnectionEvent, ConnectionState> {
  final CheckConnection _checkConnection;
  final GetConnectionStatus _getConnectionStatus;
  final WatchConnectionStatus _watchConnectionStatus;
  
  StreamSubscription? _connectionSubscription;

  /// Создает экземпляр [ConnectionBloc]
  ConnectionBloc({
    required CheckConnection checkConnection,
    required GetConnectionStatus getConnectionStatus,
    required WatchConnectionStatus watchConnectionStatus,
  })  : _checkConnection = checkConnection,
        _getConnectionStatus = getConnectionStatus,
        _watchConnectionStatus = watchConnectionStatus,
        super(const ConnectionInitial()) {
    on<CheckConnectionEvent>(_onCheckConnection);
    on<UpdateConnectionStatus>(_onUpdateConnectionStatus);
    
    // Подписываемся на изменения статуса подключения
    _connectionSubscription = _watchConnectionStatus().listen(
      (status) => add(UpdateConnectionStatus(status: status)),
    );
  }

  /// Обрабатывает событие [CheckConnectionEvent]
  Future<void> _onCheckConnection(
    CheckConnectionEvent event,
    Emitter<ConnectionState> emit,
  ) async {
    emit(const ConnectionLoading());
    
    // Проверяем наличие интернет-соединения
    final hasInternetResult = await _checkConnection(NoParams());
    
    await hasInternetResult.fold(
      (failure) async {
        emit(ConnectionError(message: failure.message));
      },
      (hasInternet) async {
        if (hasInternet) {
          // Если есть интернет, получаем подробный статус
          final statusResult = await _getConnectionStatus(NoParams());
          await statusResult.fold(
            (failure) async {
              emit(ConnectionError(message: failure.message));
            },
            (status) async {
              emit(ConnectionInfo(status: status));
            },
          );
        } else {
          // Если нет интернета, создаем статус "отключено"
          emit(const ConnectionInfo(
            status: ConnectionStatus(
              type: ConnectionType.none,
              hasInternet: false,
            ),
          ));
        }
      },
    );
  }

  /// Обрабатывает событие [UpdateConnectionStatus]
  void _onUpdateConnectionStatus(
    UpdateConnectionStatus event,
    Emitter<ConnectionState> emit,
  ) {
    emit(ConnectionInfo(status: event.status));
  }

  @override
  Future<void> close() {
    _connectionSubscription?.cancel();
    return super.close();
  }
}