import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tranzit_app/core/usecases/usecase.dart';
import 'package:tranzit_app/domain/usecases/group/get_groups.dart';
import 'package:tranzit_app/domain/usecases/group/get_group_by_id.dart';
import 'package:tranzit_app/domain/usecases/group/refresh_groups.dart' as usecase;
import 'package:tranzit_app/presentation/bloc/groups/groups_event.dart';
import 'package:tranzit_app/presentation/bloc/groups/groups_state.dart';

/// Блок для управления группами
class GroupsBloc extends Bloc<GroupsEvent, GroupsState> {
  final GetGroups _getGroups;
  final usecase.RefreshGroups _refreshGroups;
  final GetGroupById _getGroupById;

  /// Создает экземпляр [GroupsBloc]
  GroupsBloc({
    required GetGroups getGroups,
    required usecase.RefreshGroups refreshGroups,
    required GetGroupById getGroupById,
  })  : _getGroups = getGroups,
        _refreshGroups = refreshGroups,
        _getGroupById = getGroupById,
        super(const GroupsInitial()) {
    on<LoadGroups>(_onLoadGroups);
    on<RefreshGroups>(_onRefreshGroups);
    on<SelectGroup>(_onSelectGroup);
  }

  /// Обрабатывает событие [LoadGroups]
  Future<void> _onLoadGroups(
    LoadGroups event,
    Emitter<GroupsState> emit,
  ) async {
    emit(const GroupsLoading());
    final result = await _getGroups(NoParams());
    result.fold(
      (failure) => emit(GroupsError(message: failure.message)),
      (groups) => emit(GroupsLoaded(groups: groups, fromCache: true)),
    );
  }

  /// Обрабатывает событие [RefreshGroups]
  Future<void> _onRefreshGroups(
    RefreshGroups event,
    Emitter<GroupsState> emit,
  ) async {
    emit(const GroupsLoading());
    final result = await _refreshGroups(NoParams());
    result.fold(
      (failure) => emit(GroupsError(message: failure.message)),
      (groups) => emit(GroupsLoaded(groups: groups)),
    );
  }

  /// Обрабатывает событие [SelectGroup]
  Future<void> _onSelectGroup(
    SelectGroup event,
    Emitter<GroupsState> emit,
  ) async {
    if (state is GroupsLoaded) {
      final currentState = state as GroupsLoaded;
      final result = await _getGroupById(GroupParams(id: event.groupId));
      result.fold(
        (failure) => emit(GroupsError(message: failure.message)),
        (group) => emit(currentState.copyWith(selectedGroup: group)),
      );
    }
  }
}