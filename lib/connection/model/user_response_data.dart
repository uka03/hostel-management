import 'package:json_annotation/json_annotation.dart';

part 'user_response_data.g.dart';

enum UserRole { resident, manager }

enum ResidentStatus { pending, active, left }

@JsonSerializable()
class UserResponseData {
  const UserResponseData({
    required this.id,
    this.name,
    required this.role,
    required this.status,
  });

  factory UserResponseData.fromJson(Map<String, dynamic> json) =>
      _$UserResponseDataFromJson(json);

  final String id;
  final String? name;
  final UserRole role;
  final ResidentStatus status;

  Map<String, dynamic> toJson() => _$UserResponseDataToJson(this);
}
