import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hive/hive.dart';

part 'settings_model.freezed.dart';
part 'settings_model.g.dart';

@freezed
class SettingsModel with _$SettingsModel {
  @JsonSerializable(explicitToJson: true)
  const factory SettingsModel({
    @Default(false) bool isDarkMode,
    @Default(true) bool notificationsEnabled,
    @Default('ru') String language,
    DateTime? lastSyncTime,
  }) = _SettingsModel;

  factory SettingsModel.fromJson(Map<String, dynamic> json) => _$SettingsModelFromJson(json);
}

/// Адаптер для Hive для сохранения [SettingsModel]
class SettingsModelHiveAdapter extends TypeAdapter<SettingsModel> {
  @override
  final int typeId = 1;

  @override
  SettingsModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    
    return SettingsModel(
      isDarkMode: fields[0] as bool? ?? false,
      notificationsEnabled: fields[1] as bool? ?? true,
      language: fields[2] as String? ?? 'ru',
      lastSyncTime: fields[3] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, SettingsModel obj) {
    writer.writeByte(4);
    writer.writeByte(0);
    writer.write(obj.isDarkMode);
    writer.writeByte(1);
    writer.write(obj.notificationsEnabled);
    writer.writeByte(2);
    writer.write(obj.language);
    writer.writeByte(3);
    writer.write(obj.lastSyncTime);
  }
}