import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:dartz/dartz.dart';
import 'package:tranzit_app/core/errors/failures.dart';
import 'package:tranzit_app/core/usecases/usecase.dart';
import 'package:tranzit_app/domain/entities/connection_status.dart';
import 'package:tranzit_app/domain/usecases/connection/check_connection.dart';
import 'package:tranzit_app/domain/usecases/connection/get_connection_status.dart';
import 'package:tranzit_app/domain/usecases/connection/watch_connection_status.dart';
import 'package:tranzit_app/presentation/bloc/connection/connection_bloc.dart';
import 'package:tranzit_app/presentation/bloc/connection/connection_event.dart';
import 'package:tranzit_app/presentation/bloc/connection/connection_state.dart' as connection;
import 'package:bloc_test/bloc_test.dart';

import 'connection_bloc_test.mocks.dart';

@GenerateMocks([CheckConnection, GetConnectionStatus, WatchConnectionStatus])
void main() {
  late MockCheckConnection mockCheckConnection;
  late MockGetConnectionStatus mockGetConnectionStatus;
  late MockWatchConnectionStatus mockWatchConnectionStatus;
  late ConnectionBloc bloc;
  late StreamController<ConnectionStatus> connectionStreamController;

  setUp(() {
    mockCheckConnection = MockCheckConnection();
    mockGetConnectionStatus = MockGetConnectionStatus();
    mockWatchConnectionStatus = MockWatchConnectionStatus();
    connectionStreamController = StreamController<ConnectionStatus>();
    
    // Исправлено: метод call() не принимает параметров
    when(mockWatchConnectionStatus.call())
        .thenAnswer((_) => connectionStreamController.stream);
    
    bloc = ConnectionBloc(
      checkConnection: mockCheckConnection,
      getConnectionStatus: mockGetConnectionStatus,
      watchConnectionStatus: mockWatchConnectionStatus,
    );
  });

  tearDown(() {
    bloc.close();
    connectionStreamController.close();
  });

  test('начальное состояние должно быть ConnectionInitial', () {
    expect(bloc.state, equals(const connection.ConnectionInitial()));
  });

  group('CheckConnectionEvent', () {
    test(
      'должен эмитировать [ConnectionInfo] с hasInternet=true при наличии интернет-соединения',
      () async {
        // arrange
        when(mockCheckConnection(any))
            .thenAnswer((_) async => const Right(true));
        
        final tConnectionStatus = ConnectionStatus(
          type: ConnectionType.wifi,
          hasInternet: true,
        );
        
        when(mockGetConnectionStatus(any))
            .thenAnswer((_) async => Right(tConnectionStatus));
        
        // act
        bloc.add(const CheckConnectionEvent());
        
        // assert
        await expectLater(
          bloc.stream,
          emitsInOrder([
            isA<connection.ConnectionLoading>(),
            isA<connection.ConnectionInfo>(),
          ]),
        );
        
        // Дополнительная проверка после завершения потока
        verify(mockCheckConnection(NoParams()));
        verify(mockGetConnectionStatus(NoParams()));
      },
    );
    
    test(
      'должен эмитировать [ConnectionInfo] с hasInternet=false при отсутствии интернет-соединения',
      () async {
        // arrange
        when(mockCheckConnection(any))
            .thenAnswer((_) async => const Right(false));
        
        // act
        bloc.add(const CheckConnectionEvent());
        
        // assert
        await expectLater(
          bloc.stream,
          emitsInOrder([
            const connection.ConnectionLoading(),
            connection.ConnectionInfo(
              status: const ConnectionStatus(
                type: ConnectionType.none,
                hasInternet: false,
              ),
            ),
          ]),
        );
        verify(mockCheckConnection(NoParams()));
        verifyNever(mockGetConnectionStatus(any));
      },
    );

    test(
      'должен эмитировать [ConnectionError] при ошибке проверки соединения',
      () async {
        // arrange
        when(mockCheckConnection(any))
            .thenAnswer((_) async => Left(NetworkFailure(message: 'Ошибка проверки соединения')));
        
        // act
        bloc.add(const CheckConnectionEvent());
        
        // assert
        await expectLater(
          bloc.stream,
          emitsInOrder([
            const connection.ConnectionLoading(),
            const connection.ConnectionError(message: 'Ошибка проверки соединения'),
          ]),
        );
        verify(mockCheckConnection(NoParams()));
      },
    );
  });

  group('UpdateConnectionStatus', () {
    final tConnectionStatus = ConnectionStatus(
      type: ConnectionType.wifi,
      hasInternet: true,
    );

    blocTest<ConnectionBloc, connection.ConnectionState>(
      'должен эмитировать [ConnectionInfo] при получении обновления статуса подключения',
      build: () {
        return bloc;
      },
      act: (bloc) {
        bloc.add(UpdateConnectionStatus(status: tConnectionStatus));
      },
      expect: () => [
        connection.ConnectionInfo(status: tConnectionStatus),
      ],
    );

    test(
      'должен обновлять состояние при получении событий из потока',
      () async {
        // act
        connectionStreamController.add(tConnectionStatus);
        
        // assert
        await expectLater(
          bloc.stream,
          emits(connection.ConnectionInfo(status: tConnectionStatus)),
        );
        verify(mockWatchConnectionStatus.call());
      },
    );
  });
}