/// Базовый класс для исключений
class AppException implements Exception {
  /// Сообщение об ошибке
  final String message;
  
  /// Код статуса HTTP (если применимо)
  final int? statusCode;

  /// Создает экземпляр [AppException]
  const AppException({
    required this.message,
    this.statusCode,
  });

  @override
  String toString() {
    return 'AppException: $message (statusCode: $statusCode)';
  }
}

/// Исключение при ошибке сервера
class ServerException extends AppException {
  /// Создает экземпляр [ServerException]
  const ServerException({
    required String message,
    int? statusCode,
  }) : super(
          message: message,
          statusCode: statusCode,
        );
}

/// Исключение при ошибке кэша
class CacheException extends AppException {
  /// Создает экземпляр [CacheException]
  const CacheException({
    required String message,
    int? statusCode,
  }) : super(
          message: message,
          statusCode: statusCode,
        );
}

/// Исключение при ошибке сети
class NetworkException extends AppException {
  /// Создает экземпляр [NetworkException]
  const NetworkException({
    String message = 'Нет подключения к интернету',
    int? statusCode,
  }) : super(
          message: message,
          statusCode: statusCode,
        );
}