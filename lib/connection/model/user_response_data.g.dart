// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_response_data.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserResponseData _$UserResponseDataFromJson(Map<String, dynamic> json) =>
    UserResponseData(
      id: json['id'] as String,
      name: json['name'] as String?,
      role: $enumDecode(_$UserRoleEnumMap, json['role']),
      status: $enumDecode(_$ResidentStatusEnumMap, json['status']),
    );

Map<String, dynamic> _$UserResponseDataToJson(UserResponseData instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'role': _$UserRoleEnumMap[instance.role]!,
      'status': _$ResidentStatusEnumMap[instance.status]!,
    };

const _$UserRoleEnumMap = {
  UserRole.resident: 'resident',
  UserRole.manager: 'manager',
};

const _$ResidentStatusEnumMap = {
  ResidentStatus.pending: 'pending',
  ResidentStatus.active: 'active',
  ResidentStatus.left: 'left',
};
