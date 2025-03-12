import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:tranzit_app/data/models/group_model.dart';
import 'package:tranzit_app/data/models/settings_model.dart';

/// Класс для инициализации Hive
class HiveInit {
  /// Инициализирует Hive и регистрирует все адаптеры
  static Future<void> init() async {
    // Инициализация Hive
    await Hive.initFlutter();
    
    // Регистрация адаптеров
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(GroupModelHiveAdapter());
    }
    
    if (!Hive.isAdapterRegistered(1)) {
      Hive.registerAdapter(SettingsModelHiveAdapter());
    }
    
    // Логирование в режиме отладки
    if (kDebugMode) {
      print('Hive initialized successfully');
    }
  }
  
  /// Закрывает все открытые боксы Hive
  static Future<void> close() async {
    await Hive.close();
  }
  
  /// Очищает все данные Hive
  static Future<void> clearAll() async {
    await Hive.deleteFromDisk();
  }
}