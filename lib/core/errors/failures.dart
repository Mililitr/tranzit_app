import 'package:equatable/equatable.dart';

/// Базовый класс для ошибок
abstract class Failure extends Equatable {
  /// Сообщение об ошибке
  final String message;
  
  /// Код ошибки
  final int? statusCode;

  /// Создает экземпляр [Failure]
  const Failure({
    required this.message,
    this.statusCode,
  });

  @override
  List<Object?> get props => [message, statusCode];
}

/// Ошибка сервера
class ServerFailure extends Failure {
  /// Создает экземпляр [ServerFailure]
  const ServerFailure({
    required String message,
    int? statusCode,
  }) : super(
          message: message,
          statusCode: statusCode,
        );
}

/// Ошибка кэша
class CacheFailure extends Failure {
  /// Создает экземпляр [CacheFailure]
  const CacheFailure({
    required String message,
    int? statusCode,
  }) : super(
          message: message,
          statusCode: statusCode,
        );
}

/// Ошибка сети
class NetworkFailure extends Failure {
  /// Создает экземпляр [NetworkFailure]
  const NetworkFailure({
    String message = 'Нет подключения к интернету',
    int? statusCode,
  }) : super(
          message: message,
          statusCode: statusCode,
        );
}