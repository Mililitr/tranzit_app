import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hive/hive.dart';

part 'user.freezed.dart';
part 'user.g.dart';

@freezed
class User with _$User {
  @HiveType(typeId: 0)
  factory User({
    @HiveField(0)
    required String id,
    
    @HiveField(1)
    required String name,
    
    @HiveField(2)
    required String email,
    
    @HiveField(3)
    String? avatarUrl,
    
    @HiveField(4)
    @Default(false) bool isAdmin,
    
    @HiveField(5)
    @Default([]) List<String> groups,
    
    @HiveField(6)
    DateTime? lastLoginDate,
  }) = _User;

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
}