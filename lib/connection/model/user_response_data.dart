import 'package:json_annotation/json_annotation.dart';

part 'user_response_data.g.dart';

enum UserRole { resident, manager }

@JsonSerializable()
class UserResponseData {
  const UserResponseData({
    required this.id,
    required this.name,
    required this.role,
  });

  factory UserResponseData.fromJson(Map<String, dynamic> json) =>
      _$UserResponseDataFromJson(json);

  final String id;
  final String name;
  final UserRole role;

  Map<String, dynamic> toJson() => _$UserResponseDataToJson(this);
}
