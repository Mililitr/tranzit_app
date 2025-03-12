import 'package:hive/hive.dart';
import 'package:tranzit_app/core/errors/exceptions.dart';
import 'package:tranzit_app/data/models/settings_model.dart';

/// Ключ для хранилища настроек
const String settingsBoxName = 'settings_box';

/// Ключ для настроек приложения
const String appSettingsKey = 'app_settings';

/// Интерфейс для работы с локальным хранилищем настроек
abstract class SettingsLocalDataSource {
  /// Получает настройки приложения
  Future<SettingsModel> getSettings();

  /// Сохраняет настройки приложения
  Future<void> saveSettings(SettingsModel settings);

  /// Обновляет тему приложения
  Future<void> updateTheme(bool isDarkMode);
}

/// Реализация [SettingsLocalDataSource] с использованием Hive
class SettingsLocalDataSourceImpl implements SettingsLocalDataSource {
  final Box<SettingsModel> settingsBox;

  /// Создает экземпляр [SettingsLocalDataSourceImpl]
  SettingsLocalDataSourceImpl({
    required this.settingsBox,
  });

  /// Фабричный ��етод для инициализации хранилища
  static Future<SettingsLocalDataSourceImpl> init() async {
    // Регистрация адаптера для SettingsModel
    if (!Hive.isAdapterRegistered(1)) {
      Hive.registerAdapter(SettingsModelHiveAdapter());
    }

    // Открытие бокса
    final settingsBox = await Hive.openBox<SettingsModel>(settingsBoxName);

    return SettingsLocalDataSourceImpl(
      settingsBox: settingsBox,
    );
  }

  @override
  Future<SettingsModel> getSettings() async {
    try {
      final settings = settingsBox.get(appSettingsKey);
      if (settings != null) {
        return settings;
      }
      
      // Если настройки не найдены, возвращаем настройки по умолчанию
      final defaultSettings = const SettingsModel();
      await saveSettings(defaultSettings);
      return defaultSettings;
    } catch (e) {
      throw CacheException(
        message: 'Failed to get settings: $e',
      );
    }
  }

  @override
  Future<void> saveSettings(SettingsModel settings) async {
    try {
      await settingsBox.put(appSettingsKey, settings);
    } catch (e) {
      throw CacheException(
        message: 'Failed to save settings: $e',
      );
    }
  }

  @override
  Future<void> updateTheme(bool isDarkMode) async {
    try {
      final currentSettings = await getSettings();
      final updatedSettings = SettingsModel(
        isDarkMode: isDarkMode,
        notificationsEnabled: currentSettings.notificationsEnabled,
        language: currentSettings.language,
        lastSyncTime: currentSettings.lastSyncTime,
      );
      await saveSettings(updatedSettings);
    } catch (e) {
      throw CacheException(
        message: 'Failed to update theme: $e',
      );
    }
  }
}