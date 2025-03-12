import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hive/hive.dart';

part 'group_model.freezed.dart';
part 'group_model.g.dart';

@freezed
class GroupModel with _$GroupModel {
  @JsonSerializable(explicitToJson: true)
  const factory GroupModel({
    required String id,
    required String name,
    String? description,
    String? telegramLink,
    int? membersCount,
    DateTime? createdAt,
    DateTime? updatedAt,
    @Default({}) Map<String, dynamic> additionalData,
  }) = _GroupModel;

  factory GroupModel.fromJson(Map<String, dynamic> json) => _$GroupModelFromJson(json);
}

// Отдельный адаптер для Hive
class GroupModelHiveAdapter extends TypeAdapter<GroupModel> {
  @override
  final int typeId = 0;

  @override
  GroupModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    
    return GroupModel(
      id: fields[0] as String,
      name: fields[1] as String,
      description: fields[2] as String?,
      telegramLink: fields[3] as String?,
      membersCount: fields[4] as int?,
      createdAt: fields[5] as DateTime?,
      updatedAt: fields[6] as DateTime?,
      additionalData: (fields[7] as Map?)?.cast<String, dynamic>() ?? {},
    );
  }

  @override
  void write(BinaryWriter writer, GroupModel obj) {
    writer.writeByte(8);
    writer.writeByte(0);
    writer.write(obj.id);
    writer.writeByte(1);
    writer.write(obj.name);
    writer.writeByte(2);
    writer.write(obj.description);
    writer.writeByte(3);
    writer.write(obj.telegramLink);
    writer.writeByte(4);
    writer.write(obj.membersCount);
    writer.writeByte(5);
    writer.write(obj.createdAt);
    writer.writeByte(6);
    writer.write(obj.updatedAt);
    writer.writeByte(7);
    writer.write(obj.additionalData);
  }
}