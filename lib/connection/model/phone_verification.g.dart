// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'phone_verification.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PhoneVerification _$PhoneVerificationFromJson(Map<String, dynamic> json) =>
    PhoneVerification(
      sessionId: json['session_id'] as String,
      smsUri: json['sms_uri'] as String,
      displayInstruction: json['display_instruction'] as String,
      expiresAt: DateTime.parse(json['expires_at'] as String),
    );

PhoneVerificationResult _$PhoneVerificationResultFromJson(
  Map<String, dynamic> json,
) => PhoneVerificationResult(
  status: $enumDecode(_$PhoneVerificationStatusEnumMap, json['status']),
  session: json['session'] == null
      ? null
      : AuthSession.fromJson(json['session'] as Map<String, dynamic>),
);

const _$PhoneVerificationStatusEnumMap = {
  PhoneVerificationStatus.pending: 'PENDING',
  PhoneVerificationStatus.verified: 'VERIFIED',
  PhoneVerificationStatus.expired: 'EXPIRED',
};
