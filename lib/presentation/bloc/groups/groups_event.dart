import 'package:equatable/equatable.dart';

/// События для [GroupsBloc]
abstract class GroupsEvent extends Equatable {
  const GroupsEvent();

  @override
  List<Object?> get props => [];
}

/// Событие для загрузки групп
class LoadGroups extends GroupsEvent {
  const LoadGroups();
}

/// Событие для обновления групп с сервера
class RefreshGroups extends GroupsEvent {
  const RefreshGroups();
}

/// Событие для выбора группы
class SelectGroup extends GroupsEvent {
  /// ID выбранной группы
  final String groupId;

  /// Создает экземпляр [SelectGroup]
  const SelectGroup({required this.groupId});

  @override
  List<Object?> get props => [groupId];
}