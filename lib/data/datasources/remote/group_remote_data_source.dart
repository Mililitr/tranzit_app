import 'package:dio/dio.dart';
import 'package:tranzit_app/core/constants/api_constants.dart';
import 'package:tranzit_app/core/errors/exceptions.dart';
import 'package:tranzit_app/data/models/group_model.dart';

/// Интерфейс для удаленного источника данных групп
abstract class GroupRemoteDataSource {
  /// Получает список групп с сервера
  Future<List<GroupModel>> getGroups();
}

/// Реализация [GroupRemoteDataSource] с использованием Dio
class GroupRemoteDataSourceImpl implements GroupRemoteDataSource {
  final Dio client;

  /// Создает экземпляр [GroupRemoteDataSourceImpl]
  GroupRemoteDataSourceImpl({
    required this.client,
  });

  @override
  Future<List<GroupModel>> getGroups() async {
    try {
      final response = await client.get(
        ApiConstants.groupsEndpoint,
        options: Options(
          headers: {
            'Authorization': 'Bearer ${ApiConstants.apiToken}',
          },
        ),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data;
        
        // Обработка разных форматов ответа
        if (response.data is List) {
          data = response.data;
        } else if (response.data is Map && response.data.containsKey('data')) {
          data = response.data['data'];
        } else {
          throw ServerException(message: 'Неожиданный формат ответа');
        }
        
        // Преобразование данных API в модели
        return data.map((item) => GroupModel(
          id: item['id'].toString(),
          name: item['summary'] ?? '',
          description: _cleanHtmlTags(item['description'] ?? ''),
          telegramLink: _extractTelegramLink(item['url'] ?? '', item['description'] ?? ''),
          membersCount: null, // API не предоставляет это поле
          createdAt: _parseDateTime(item['date_add']),
          updatedAt: _parseDateTime(item['date_stamp']),
          additionalData: {
            'location': item['location_text'] ?? '',
            'organizer': item['organizer'] ?? '',
            'date_start': item['date_start'] ?? '',
            'date_end': item['date_end'] ?? '',
            'rrule': item['rrule'] ?? '',
          },
        )).toList();
      } else {
        throw ServerException(
          message: 'Ошибка сервера: ${response.statusCode}',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      throw ServerException(
        message: 'Ошибка сети: ${e.message}',
        statusCode: e.response?.statusCode,
      );
    } on Exception catch (e) {
      throw ServerException(
        message: 'Непредвиденная ошибка: $e',
      );
    }
  }

  // Вспомогательный метод для очистки HTML-тегов
  String _cleanHtmlTags(String htmlText) {
    // Простая реализация - можно улучшить с помощью html пакета
    return htmlText.replaceAll(RegExp(r'<[^>]*>'), '');
  }

  // Вспомогательный метод для извлечения Telegram-ссылки
  String _extractTelegramLink(String url, String description) {
    if (url.contains('t.me')) {
      return url;
    }
    
    // Попытка найти ссылку в описании
    final telegramLinkRegex = RegExp('https?:\/\/t\.me\/[^\s\'"<>]+');
    final match = telegramLinkRegex.firstMatch(description);
    if (match != null) {
      return match.group(0) ?? '';
    }
    
    return '';
  }

  // Вспомогательный метод для парсинга даты
  DateTime? _parseDateTime(String? dateString) {
    if (dateString == null || dateString.isEmpty) {
      return null;
    }
    
    try {
      return DateTime.parse(dateString);
    } catch (e) {
      return null;
    }
  }
}