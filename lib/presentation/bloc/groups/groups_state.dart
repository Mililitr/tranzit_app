import 'package:equatable/equatable.dart';
import 'package:tranzit_app/domain/entities/group.dart';

/// Состояния для [GroupsBloc]
abstract class GroupsState extends Equatable {
  const GroupsState();

  @override
  List<Object?> get props => [];
}

/// Начальное состояние
class GroupsInitial extends GroupsState {
  const GroupsInitial();
}

/// Состояние загрузки
class GroupsLoading extends GroupsState {
  const GroupsLoading();
}

/// Состояние успешной загрузки
class GroupsLoaded extends GroupsState {
  /// Список групп
  final List<Group> groups;
  
  /// Выбранная группа
  final Group? selectedGroup;
  
  /// Флаг, указывающий, что данные загружены из кэша
  final bool fromCache;

  /// Создает экземпляр [GroupsLoaded]
  const GroupsLoaded({
    required this.groups,
    this.selectedGroup,
    this.fromCache = false,
  });

  @override
  List<Object?> get props => [groups, selectedGroup, fromCache];

  /// Создает копию с новыми значениями
  GroupsLoaded copyWith({
    List<Group>? groups,
    Group? selectedGroup,
    bool? fromCache,
  }) {
    return GroupsLoaded(
      groups: groups ?? this.groups,
      selectedGroup: selectedGroup ?? this.selectedGroup,
      fromCache: fromCache ?? this.fromCache,
    );
  }
}

/// Состояние ошибки
class GroupsError extends GroupsState {
  /// Сообщение об ошибке
  final String message;

  /// Создает экземпляр [GroupsError]
  const GroupsError({required this.message});

  @override
  List<Object?> get props => [message];
}