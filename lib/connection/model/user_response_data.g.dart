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
      bankName: json['bank_name'] as String?,
      bankAccountNumber: json['bank_account_number'] as String?,
      bankAccountHolder: json['bank_account_holder'] as String?,
      notificationsEnabled: json['notifications_enabled'] as bool?,
      language: json['language'] as String?,
    );

Map<String, dynamic> _$UserResponseDataToJson(UserResponseData instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': ?instance.name,
      'role': _$UserRoleEnumMap[instance.role]!,
      'status': _$ResidentStatusEnumMap[instance.status]!,
      'bank_name': ?instance.bankName,
      'bank_account_number': ?instance.bankAccountNumber,
      'bank_account_holder': ?instance.bankAccountHolder,
      'notifications_enabled': ?instance.notificationsEnabled,
      'language': ?instance.language,
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
