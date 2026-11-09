import 'package:json_annotation/json_annotation.dart';

part 'auth_session.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake, explicitToJson: true)
class AuthSession {
  const AuthSession({
    required this.accessToken,
    required this.refreshToken,
    required this.expiresAt,
    required this.user,
  });

  factory AuthSession.fromJson(Map<String, dynamic> json) =>
      _$AuthSessionFromJson(json);

  final String accessToken;
  final String refreshToken;

  /// Seconds since the Unix epoch.
  final int expiresAt;
  final AuthUser user;

  /// True when the token has expired or will within a minute.
  bool isExpiringAt(DateTime now) =>
      now.millisecondsSinceEpoch ~/ 1000 >= expiresAt - 60;

  Map<String, dynamic> toJson() => _$AuthSessionToJson(this);
}

@JsonSerializable()
class AuthUser {
  const AuthUser({required this.id, this.phone});

  factory AuthUser.fromJson(Map<String, dynamic> json) =>
      _$AuthUserFromJson(json);

  final String id;
  final String? phone;

  Map<String, dynamic> toJson() => _$AuthUserToJson(this);
}
