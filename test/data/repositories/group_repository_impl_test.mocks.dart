// Mocks generated by Mockito 5.4.4 from annotations
// in tranzit_app/test/data/repositories/group_repository_impl_test.dart.
// Do not manually edit this file.

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'dart:async' as _i3;

import 'package:mockito/mockito.dart' as _i1;
import 'package:tranzit_app/core/network/network_info.dart' as _i6;
import 'package:tranzit_app/data/datasources/local/group_local_data_source.dart'
    as _i5;
import 'package:tranzit_app/data/datasources/remote/group_remote_data_source.dart'
    as _i2;
import 'package:tranzit_app/data/models/group_model.dart' as _i4;

// ignore_for_file: type=lint
// ignore_for_file: avoid_redundant_argument_values
// ignore_for_file: avoid_setters_without_getters
// ignore_for_file: comment_references
// ignore_for_file: deprecated_member_use
// ignore_for_file: deprecated_member_use_from_same_package
// ignore_for_file: implementation_imports
// ignore_for_file: invalid_use_of_visible_for_testing_member
// ignore_for_file: prefer_const_constructors
// ignore_for_file: unnecessary_parenthesis
// ignore_for_file: camel_case_types
// ignore_for_file: subtype_of_sealed_class

/// A class which mocks [GroupRemoteDataSource].
///
/// See the documentation for Mockito's code generation for more information.
class MockGroupRemoteDataSource extends _i1.Mock
    implements _i2.GroupRemoteDataSource {
  MockGroupRemoteDataSource() {
    _i1.throwOnMissingStub(this);
  }

  @override
  _i3.Future<List<_i4.GroupModel>> getGroups() => (super.noSuchMethod(
        Invocation.method(
          #getGroups,
          [],
        ),
        returnValue: _i3.Future<List<_i4.GroupModel>>.value(<_i4.GroupModel>[]),
      ) as _i3.Future<List<_i4.GroupModel>>);
}

/// A class which mocks [GroupLocalDataSource].
///
/// See the documentation for Mockito's code generation for more information.
class MockGroupLocalDataSource extends _i1.Mock
    implements _i5.GroupLocalDataSource {
  MockGroupLocalDataSource() {
    _i1.throwOnMissingStub(this);
  }

  @override
  _i3.Future<List<_i4.GroupModel>> getGroups() => (super.noSuchMethod(
        Invocation.method(
          #getGroups,
          [],
        ),
        returnValue: _i3.Future<List<_i4.GroupModel>>.value(<_i4.GroupModel>[]),
      ) as _i3.Future<List<_i4.GroupModel>>);

  @override
  _i3.Future<void> cacheGroups(List<_i4.GroupModel>? groups) =>
      (super.noSuchMethod(
        Invocation.method(
          #cacheGroups,
          [groups],
        ),
        returnValue: _i3.Future<void>.value(),
        returnValueForMissingStub: _i3.Future<void>.value(),
      ) as _i3.Future<void>);

  @override
  _i3.Future<DateTime?> getLastUpdateTime() => (super.noSuchMethod(
        Invocation.method(
          #getLastUpdateTime,
          [],
        ),
        returnValue: _i3.Future<DateTime?>.value(),
      ) as _i3.Future<DateTime?>);

  @override
  _i3.Future<void> saveLastUpdateTime(DateTime? time) => (super.noSuchMethod(
        Invocation.method(
          #saveLastUpdateTime,
          [time],
        ),
        returnValue: _i3.Future<void>.value(),
        returnValueForMissingStub: _i3.Future<void>.value(),
      ) as _i3.Future<void>);

  @override
  _i3.Future<void> clearCache() => (super.noSuchMethod(
        Invocation.method(
          #clearCache,
          [],
        ),
        returnValue: _i3.Future<void>.value(),
        returnValueForMissingStub: _i3.Future<void>.value(),
      ) as _i3.Future<void>);
}

/// A class which mocks [NetworkInfo].
///
/// See the documentation for Mockito's code generation for more information.
class MockNetworkInfo extends _i1.Mock implements _i6.NetworkInfo {
  MockNetworkInfo() {
    _i1.throwOnMissingStub(this);
  }

  @override
  _i3.Future<bool> get isConnected => (super.noSuchMethod(
        Invocation.getter(#isConnected),
        returnValue: _i3.Future<bool>.value(false),
      ) as _i3.Future<bool>);
}
