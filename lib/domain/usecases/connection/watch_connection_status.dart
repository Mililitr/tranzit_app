import 'package:tranzit_app/domain/entities/connection_status.dart';
import 'package:tranzit_app/domain/repositories/connection_repository.dart';

/// Use case для наблюдения за изменениями статуса подключения
class WatchConnectionStatus {
  final ConnectionRepository repository;

  /// Создает экземпляр [WatchConnectionStatus]
  WatchConnectionStatus(this.repository);

  /// Возвращает поток изменений статуса подключения
  Stream<ConnectionStatus> call() {
    return repository.connectionStatusStream;
  }
}