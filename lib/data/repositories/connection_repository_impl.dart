import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:tranzit_app/core/errors/failures.dart';
import 'package:tranzit_app/domain/entities/connection_status.dart';
import 'package:tranzit_app/domain/repositories/connection_repository.dart';

/// Реализация [ConnectionRepository]
class ConnectionRepositoryImpl implements ConnectionRepository {
  final InternetConnectionChecker connectionChecker;
  final StreamController<ConnectionStatus> _connectionStatusController = 
      StreamController<ConnectionStatus>.broadcast();

  /// Создает экземпляр [ConnectionRepositoryImpl]
  ConnectionRepositoryImpl({
    required this.connectionChecker,
  }) {
    // Подписываемся на изменения статуса подключения
    connectionChecker.onStatusChange.listen((status) {
      final hasConnection = status == InternetConnectionStatus.connected;
      final connectionType = hasConnection ? ConnectionType.wifi : ConnectionType.none;
      
      _connectionStatusController.add(
        ConnectionStatus(
          type: connectionType,
          hasInternet: hasConnection,
        ),
      );
    });
  }

  @override
  Future<Either<Failure, bool>> hasInternetConnection() async {
    try {
      final hasConnection = await connectionChecker.hasConnection;
      return Right(hasConnection);
    } catch (e) {
      return const Left(
        NetworkFailure(message: 'Ошибка при проверке подключения'),
      );
    }
  }

  @override
  Future<Either<Failure, ConnectionStatus>> getConnectionStatus() async {
    try {
      final hasConnection = await connectionChecker.hasConnection;
      final connectionType = hasConnection ? ConnectionType.wifi : ConnectionType.none;
      
      return Right(
        ConnectionStatus(
          type: connectionType,
          hasInternet: hasConnection,
        ),
      );
    } catch (e) {
      return const Left(
        NetworkFailure(message: 'Ошибка при получении статуса подключения'),
      );
    }
  }

  @override
  Stream<ConnectionStatus> get connectionStatusStream => _connectionStatusController.stream;
}