import 'package:hostel/connection/model/auth_session.dart';
import 'package:json_annotation/json_annotation.dart';

part 'phone_verification.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake, createToJson: false)
class PhoneVerification {
  const PhoneVerification({
    required this.sessionId,
    required this.smsUri,
    required this.displayInstruction,
    required this.expiresAt,
  });

  factory PhoneVerification.fromJson(Map<String, dynamic> json) =>
      _$PhoneVerificationFromJson(json);

  final String sessionId;

  /// Opens the SMS app with the number and code filled in.
  final String smsUri;

  /// verify.mn's own wording of the instruction. Any replacement shown to the
  /// resident must still name the number they have to send from.
  final String displayInstruction;
  final DateTime expiresAt;

  /// The number to text, taken from [smsUri].
  String get recipient => Uri.parse(smsUri).path;

  /// The code to send, taken from [smsUri].
  String get code => Uri.parse(smsUri).queryParameters['body'] ?? '';
}

@JsonEnum(fieldRename: FieldRename.screamingSnake)
enum PhoneVerificationStatus { pending, verified, expired }

@JsonSerializable(createToJson: false)
class PhoneVerificationResult {
  const PhoneVerificationResult({required this.status, this.session});

  factory PhoneVerificationResult.fromJson(Map<String, dynamic> json) =>
      _$PhoneVerificationResultFromJson(json);

  final PhoneVerificationStatus status;

  /// Present only when [status] is verified.
  final AuthSession? session;
}
