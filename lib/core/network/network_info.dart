import 'package:internet_connection_checker/internet_connection_checker.dart';

/// Интерфейс для проверки сетевого подключения
abstract class NetworkInfo {
  /// Проверяет наличие интернет-соединения
  Future<bool> get isConnected;
}

/// Реализация [NetworkInfo] с использованием InternetConnectionChecker
class NetworkInfoImpl implements NetworkInfo {
  final InternetConnectionChecker connectionChecker;

  /// Создает экземпляр [NetworkInfoImpl]
  NetworkInfoImpl({required this.connectionChecker});

  @override
  Future<bool> get isConnected => connectionChecker.hasConnection;
}