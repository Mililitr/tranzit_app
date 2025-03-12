import 'package:equatable/equatable.dart';

/// Сущность группы
class Group extends Equatable {
  /// Уникальный идентификатор
  final String id;
  
  /// Название группы
  final String name;
  
  /// Описание группы
  final String? description;
  
  /// Ссылка на группу в Telegram
  final String? telegramLink;
  
  /// Количество участников
  final int? membersCount;
  
  /// Дата создания
  final DateTime? createdAt;
  
  /// Дата обновления
  final DateTime? updatedAt;
  
  /// Дополнительные данные
  final Map<String, dynamic> additionalData;

  /// Создает экземпляр [Group]
  const Group({
    required this.id,
    required this.name,
    this.description,
    this.telegramLink,
    this.membersCount,
    this.createdAt,
    this.updatedAt,
    this.additionalData = const {},
  });

  @override
  List<Object?> get props => [
    id,
    name,
    description,
    telegramLink,
    membersCount,
    createdAt,
    updatedAt,
    additionalData,
  ];
}