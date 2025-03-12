import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:tranzit_app/core/errors/failures.dart';

/// Базовый интерфейс для всех use cases
abstract class UseCase<Type, Params> {
  /// Выполняет use case с заданными параметрами
  Future<Either<Failure, Type>> call(Params params);
}

/// Класс для use cases без параметров
class NoParams extends Equatable {
  @override
  List<Object> get props => [];
}