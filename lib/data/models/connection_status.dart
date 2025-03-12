import 'package:freezed_annotation/freezed_annotation.dart';

part 'connection_status.freezed.dart';
part 'connection_status.g.dart';

/// Модель для отслеживания состояния подключения к сети
@freezed
class ConnectionStatus with _$ConnectionStatus {
  /// Создает статус подключения
  const factory ConnectionStatus({
    /// Флаг наличия подключения к интернету
    required bool isConnected,
    
    /// Тип подключения (wifi, mobile, none)
    @Default('unknown') String connectionType,
    
    /// Временная метка последней проверки
    DateTime? lastChecked,
  }) = _ConnectionStatus;

  /// Создает статус подключения из JSON
  factory ConnectionStatus.fromJson(Map<String, dynamic> json) => 
      _$ConnectionStatusFromJson(json);
      
  /// Фабричный метод для создания статуса "подключено"
  factory ConnectionStatus.connected({String connectionType = 'unknown'}) => 
      ConnectionStatus(
        isConnected: true,
        connectionType: connectionType,
        lastChecked: DateTime.now(),
      );
      
  /// Фабричный метод для создания статуса "отключено"
  factory ConnectionStatus.disconnected() => ConnectionStatus(
        isConnected: false,
        connectionType: 'none',
        lastChecked: DateTime.now(),
      );
}