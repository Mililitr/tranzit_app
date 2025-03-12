import 'package:equatable/equatable.dart';
import 'package:tranzit_app/domain/entities/connection_status.dart';

/// Состояния для [ConnectionBloc]
abstract class ConnectionState extends Equatable {
  const ConnectionState();

  @override
  List<Object?> get props => [];
}

/// Начальное состояние
class ConnectionInitial extends ConnectionState {
  const ConnectionInitial();
}

/// Состояние загрузки
class ConnectionLoading extends ConnectionState {
  const ConnectionLoading();
}

/// Состояние с информацией о соединении
class ConnectionInfo extends ConnectionState {
  /// Статус соединения
  final ConnectionStatus status;

  /// Создает экземпляр [ConnectionInfo]
  const ConnectionInfo({required this.status});

  @override
  List<Object?> get props => [status];
}

/// Состояние ошибки
class ConnectionError extends ConnectionState {
  /// Сообщение об ошибке
  final String message;

  /// Создает экземпляр [ConnectionError]
  const ConnectionError({required this.message});

  @override
  List<Object?> get props => [message];
}