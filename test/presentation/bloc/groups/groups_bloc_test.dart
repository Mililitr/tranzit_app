import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:tranzit_app/core/errors/failures.dart';
import 'package:tranzit_app/core/usecases/usecase.dart';
import 'package:tranzit_app/domain/entities/group.dart';
import 'package:tranzit_app/domain/usecases/group/get_group_by_id.dart';
import 'package:tranzit_app/domain/usecases/group/get_groups.dart';
import 'package:tranzit_app/domain/usecases/group/refresh_groups.dart' as usecase;
import 'package:tranzit_app/presentation/bloc/groups/groups_bloc.dart';
import 'package:tranzit_app/presentation/bloc/groups/groups_event.dart';
import 'package:tranzit_app/presentation/bloc/groups/groups_state.dart';
import 'package:bloc_test/bloc_test.dart';

import 'groups_bloc_test.mocks.dart';

@GenerateMocks([GetGroups, usecase.RefreshGroups, GetGroupById])
void main() {
  late MockGetGroups mockGetGroups;
  late MockRefreshGroups mockRefreshGroups;
  late MockGetGroupById mockGetGroupById;
  late GroupsBloc bloc;

  setUp(() {
    mockGetGroups = MockGetGroups();
    mockRefreshGroups = MockRefreshGroups();
    mockGetGroupById = MockGetGroupById();
    bloc = GroupsBloc(
      getGroups: mockGetGroups,
      refreshGroups: mockRefreshGroups,
      getGroupById: mockGetGroupById,
    );
  });

  tearDown(() {
    bloc.close();
  });

  test('начальное состояние должно быть GroupsInitial', () {
    expect(bloc.state, equals(const GroupsInitial()));
  });

  group('LoadGroups', () {
    final tGroups = [
      Group(
        id: '1',
        name: 'Test Group 1',
        description: 'Description 1',
        telegramLink: 'https://t.me/group1',
      ),
      Group(
        id: '2',
        name: 'Test Group 2',
        description: 'Description 2',
        telegramLink: 'https://t.me/group2',
      ),
    ];

    blocTest<GroupsBloc, GroupsState>(
      'должен эмитировать [GroupsLoading, GroupsLoaded] при успешной загрузке групп',
      build: () {
        when(mockGetGroups(any))
            .thenAnswer((_) async => Right(tGroups));
        return bloc;
      },
      act: (bloc) => bloc.add(const LoadGroups()),
      expect: () => [
        const GroupsLoading(),
        GroupsLoaded(groups: tGroups, fromCache: true),
      ],
      verify: (_) {
        verify(mockGetGroups(NoParams()));
      },
    );

    blocTest<GroupsBloc, GroupsState>(
      'должен эмитировать [GroupsLoading, GroupsError] при ошибке загрузки групп',
      build: () {
        when(mockGetGroups(any))
            .thenAnswer((_) async => Left(ServerFailure(message: 'Ошибка загрузки')));
        return bloc;
      },
      act: (bloc) => bloc.add(const LoadGroups()),
      expect: () => [
        const GroupsLoading(),
        const GroupsError(message: 'Ошибка загрузки'),
      ],
      verify: (_) {
        verify(mockGetGroups(NoParams()));
      },
    );
  });

  group('RefreshGroups', () {
    final tGroups = [
      Group(
        id: '1',
        name: 'Test Group 1',
        description: 'Description 1',
        telegramLink: 'https://t.me/group1',
      ),
      Group(
        id: '2',
        name: 'Test Group 2',
        description: 'Description 2',
        telegramLink: 'https://t.me/group2',
      ),
    ];

    blocTest<GroupsBloc, GroupsState>(
      'должен эмитировать [GroupsLoading, GroupsLoaded] при успешном обновлении групп',
      build: () {
        when(mockRefreshGroups(any))
            .thenAnswer((_) async => Right(tGroups));
        return bloc;
      },
      act: (bloc) => bloc.add(const RefreshGroups()),
      expect: () => [
        const GroupsLoading(),
        GroupsLoaded(groups: tGroups),
      ],
      verify: (_) {
        verify(mockRefreshGroups(NoParams()));
      },
    );

    blocTest<GroupsBloc, GroupsState>(
      'должен эмитировать [GroupsLoading, GroupsError] при ошибке обновления групп',
      build: () {
        when(mockRefreshGroups(any))
            .thenAnswer((_) async => Left(NetworkFailure(message: 'Нет подключения к интернету')));
        return bloc;
      },
      act: (bloc) => bloc.add(const RefreshGroups()),
      expect: () => [
        const GroupsLoading(),
        const GroupsError(message: 'Нет подключения к интернету'),
      ],
      verify: (_) {
        verify(mockRefreshGroups(NoParams()));
      },
    );
  });

  group('SelectGroup', () {
    final tGroupId = '1';
    final tGroup = Group(
      id: '1',
      name: 'Test Group 1',
      description: 'Description 1',
      telegramLink: 'https://t.me/group1',
    );
    final tGroups = [
      tGroup,
      Group(
        id: '2',
        name: 'Test Group 2',
        description: 'Description 2',
        telegramLink: 'https://t.me/group2',
      ),
    ];

    blocTest<GroupsBloc, GroupsState>(
      'должен эмитировать [GroupsLoaded] с выбранной группой при успешном выборе группы',
      build: () {
        when(mockGetGroupById(any))
            .thenAnswer((_) async => Right(tGroup));
        return bloc;
      },
      seed: () => GroupsLoaded(groups: tGroups),
      act: (bloc) => bloc.add(SelectGroup(groupId: tGroupId)),
      expect: () => [
        GroupsLoaded(groups: tGroups, selectedGroup: tGroup),
      ],
      verify: (_) {
        verify(mockGetGroupById(GroupParams(id: tGroupId)));
      },
    );

    blocTest<GroupsBloc, GroupsState>(
      'должен эмитировать [GroupsError] при ошибке выбора группы',
      build: () {
        when(mockGetGroupById(any))
            .thenAnswer((_) async => Left(CacheFailure(message: 'Группа не найдена')));
        return bloc;
      },
      seed: () => GroupsLoaded(groups: tGroups),
      act: (bloc) => bloc.add(SelectGroup(groupId: tGroupId)),
      expect: () => [
        const GroupsError(message: 'Группа не найдена'),
      ],
      verify: (_) {
        verify(mockGetGroupById(GroupParams(id: tGroupId)));
      },
    );

    test('не должен эмитировать новые состояния, если текущее состояние не GroupsLoaded', () {
      // arrange
      when(mockGetGroupById(any))
          .thenAnswer((_) async => Right(tGroup));
      
      // act
      bloc.add(SelectGroup(groupId: tGroupId));
      
      // assert
      expectLater(bloc.stream, emitsInOrder([]));
    });
  });
}