import 'package:equatable/equatable.dart';
import 'package:tranzit_app/domain/entities/connection_status.dart';

/// События для [ConnectionBloc]
abstract class ConnectionEvent extends Equatable {
  const ConnectionEvent();

  @override
  List<Object?> get props => [];
}

/// Событие для проверки соединения
class CheckConnectionEvent extends ConnectionEvent {
  const CheckConnectionEvent();
}

/// Событие для обновления статуса соединения
class UpdateConnectionStatus extends ConnectionEvent {
  /// Новый статус соединения
  final ConnectionStatus status;

  /// Создает экземпляр [UpdateConnectionStatus]
  const UpdateConnectionStatus({required this.status});

  @override
  List<Object?> get props => [status];
}