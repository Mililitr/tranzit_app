/// Константы для работы с API
class ApiConstants {
  /// Базовый URL API
  static const String baseUrl = 'https://api.wayhomeapp.org';
  
  /// Эндпоинт для получения групп
  static const String groupsEndpoint = '/tranzit/';
  
  /// API токен для авторизации
  static const String apiToken = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjE3MTkxNDM5MjEsImlkIjoiNTkiLCJuYW1lIjoiZmRhMmFmYmI3ZmRjMjE3NzU3MjQzODE4MmQ1MGVjZDMiLCJleHAiOjE3MTkxNDM5ODF9.1MU6c64soxKhagDtOqeIMbwuCH5Ng2wWTl6NxgeuJMs';
  
  /// Тайм-аут соединения (в секундах)
  static const int connectionTimeout = 5;
  
  /// Тайм-аут получения данных (в секундах)
  static const int receiveTimeout = 3;
}