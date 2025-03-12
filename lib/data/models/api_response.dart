import 'package:freezed_annotation/freezed_annotation.dart';

part 'api_response.freezed.dart';
part 'api_response.g.dart';

@Freezed(genericArgumentFactories: true)
class ApiResponse<T> with _$ApiResponse<T> {
  const factory ApiResponse({
    required bool success,
    String? message,
    T? data,
    @Default([]) List<String> errors,
  }) = _ApiResponse;

  factory ApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Object?) fromJsonT,
  ) => _$ApiResponseFromJson(json, fromJsonT);

  // Вспомогательные фабричные методы
  factory ApiResponse.success(T data) => ApiResponse(
        success: true,
        data: data,
      );

  factory ApiResponse.error(String message, [List<String> errors = const []]) => ApiResponse(
        success: false,
        message: message,
        errors: errors,
      );

  factory ApiResponse.loading() => const ApiResponse(
        success: true,
        message: 'Loading...',
      );
}

@Freezed(genericArgumentFactories: true)
class ApiListResponse<T> with _$ApiListResponse<T> {
  const factory ApiListResponse({
    required bool success,
    String? message,
    @Default([]) List<T> data,
    @Default([]) List<String> errors,
  }) = _ApiListResponse;

  factory ApiListResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Object?) fromJsonT,
  ) => _$ApiListResponseFromJson(json, fromJsonT);

  // Вспомогательные фабричные методы
  factory ApiListResponse.success(List<T> data) => ApiListResponse(
        success: true,
        data: data,
      );

  factory ApiListResponse.error(String message, [List<String> errors = const []]) => ApiListResponse(
        success: false,
        message: message,
        errors: errors,
      );

  factory ApiListResponse.loading() => const ApiListResponse(
        success: true,
        message: 'Loading...',
      );
}