import 'package:hive/hive.dart';
import 'package:tranzit_app/core/errors/exceptions.dart';
import 'package:tranzit_app/data/models/group_model.dart';

/// Ключ для хранилища групп
const String groupsBoxName = 'groups_box';

/// Ключ для последнего обновления
const String lastUpdateKey = 'last_update';

/// Интерфейс для работы с локальным хранилищем групп
abstract class GroupLocalDataSource {
  /// Получает список всех групп из локального хранилища
  Future<List<GroupModel>> getGroups();

  /// Сохраняет список групп в локальное хранилище
  Future<void> cacheGroups(List<GroupModel> groups);

  /// Получает время последнего обновления данных
  Future<DateTime?> getLastUpdateTime();

  /// Сохраняет время последнего обновления данных
  Future<void> saveLastUpdateTime(DateTime time);

  /// Очищает кэш групп
  Future<void> clearCache();
}

/// Реализация [GroupLocalDataSource] с использованием Hive
class GroupLocalDataSourceImpl implements GroupLocalDataSource {
  final Box<GroupModel> groupsBox;
  final Box<dynamic> metadataBox;

  /// Создает экземпляр [GroupLocalDataSourceImpl]
  GroupLocalDataSourceImpl({
    required this.groupsBox,
    required this.metadataBox,
  });

  @override
  Future<List<GroupModel>> getGroups() async {
    try {
      final groups = groupsBox.values.toList();
      if (groups.isEmpty) {
        throw const CacheException(
          message: 'No cached groups found',
        );
      }
      return groups;
    } catch (e) {
      if (e is CacheException) rethrow;
      throw CacheException(
        message: 'Failed to get groups from cache: $e',
      );
    }
  }

  @override
  Future<void> cacheGroups(List<GroupModel> groups) async {
    try {
      // Очищаем текущий кэш
      await groupsBox.clear();
      
      // Сохраняем новые данные
      for (var i = 0; i < groups.length; i++) {
        await groupsBox.put(i, groups[i]);
      }
      
      // Обновляем время последнего обновления
      await saveLastUpdateTime(DateTime.now());
    } catch (e) {
      throw CacheException(
        message: 'Failed to cache groups: $e',
      );
    }
  }

  @override
  Future<DateTime?> getLastUpdateTime() async {
    try {
      final timestamp = metadataBox.get(lastUpdateKey);
      if (timestamp != null) {
        return DateTime.fromMillisecondsSinceEpoch(timestamp as int);
      }
      return null;
    } catch (e) {
      throw CacheException(
        message: 'Failed to get last update time: $e',
      );
    }
  }

  @override
  Future<void> saveLastUpdateTime(DateTime time) async {
    try {
      await metadataBox.put(
        lastUpdateKey,
        time.millisecondsSinceEpoch,
      );
    } catch (e) {
      throw CacheException(
        message: 'Failed to save last update time: $e',
      );
    }
  }

  @override
  Future<void> clearCache() async {
    try {
      await groupsBox.clear();
      await metadataBox.delete(lastUpdateKey);
    } catch (e) {
      throw CacheException(
        message: 'Failed to clear cache: $e',
      );
    }
  }
}