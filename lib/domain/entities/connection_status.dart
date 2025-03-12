import 'package:equatable/equatable.dart';

/// Тип подключения
enum ConnectionType {
  /// Нет подключения
  none,
  
  /// Мобильная сеть
  mobile,
  
  /// Wi-Fi
  wifi,
  
  /// Ethernet
  ethernet,
  
  /// Другой тип
  other
}

/// Статус подключения к сети
class ConnectionStatus extends Equatable {
  /// Тип подключения
  final ConnectionType type;
  
  /// Наличие интернет-соединения
  final bool hasInternet;

  /// Создает экземпляр [ConnectionStatus]
  const ConnectionStatus({
    required this.type,
    required this.hasInternet,
  });

  @override
  List<Object?> get props => [type, hasInternet];
}