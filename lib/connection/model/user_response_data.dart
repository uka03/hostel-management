import 'package:json_annotation/json_annotation.dart';

part 'user_response_data.g.dart';

enum UserRole { resident, manager }

enum ResidentStatus { pending, active, left }

@JsonSerializable(includeIfNull: false)
class UserResponseData {
  const UserResponseData({
    required this.id,
    this.name,
    required this.role,
    required this.status,
    this.bankName,
    this.bankAccountNumber,
    this.bankAccountHolder,
    this.notificationsEnabled,
    this.language,
  });

  factory UserResponseData.fromJson(Map<String, dynamic> json) =>
      _$UserResponseDataFromJson(json);

  final String id;
  final String? name;
  final UserRole role;
  final ResidentStatus status;

  @JsonKey(name: 'bank_name')
  final String? bankName;
  @JsonKey(name: 'bank_account_number')
  final String? bankAccountNumber;
  @JsonKey(name: 'bank_account_holder')
  final String? bankAccountHolder;
  @JsonKey(name: 'notifications_enabled')
  final bool? notificationsEnabled;

  /// `mn` or `en`.
  final String? language;

  Map<String, dynamic> toJson() => _$UserResponseDataToJson(this);
}
