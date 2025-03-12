import 'package:dartz/dartz.dart';
import 'package:tranzit_app/core/errors/failures.dart';
import 'package:tranzit_app/domain/entities/connection_status.dart';

/// Интерфейс репозитория для работы с подключением
abstract class ConnectionRepository {
  /// Проверяет наличие интернет-соединения
  /// 
  /// Возвращает [Either] с [bool] в случае успеха
  /// или [Failure] в случае ошибки
  Future<Either<Failure, bool>> hasInternetConnection();
  
  /// Получает текущий статус подключения
  /// 
  /// Возвращает [Either] с [ConnectionStatus] в случае успеха
  /// или [Failure] в случае ошибки
  Future<Either<Failure, ConnectionStatus>> getConnectionStatus();
  
  /// Возвращает поток изменений статуса подключения
  Stream<ConnectionStatus> get connectionStatusStream;
}