import 'package:dio/dio.dart';
import 'package:hostel/connection/model/auth_session.dart';
import 'package:hostel/connection/model/phone_verification.dart';
import 'package:hostel/connection/model/user_response_data.dart';
import 'package:hostel/connection/network_interceptor.dart';

/// Login and session calls over the shared Dio instance.
class AuthApi {
  AuthApi(this._dio);

  final Dio _dio;

  static const _phoneVerifyPath = '/functions/v1/phone-verify';
  static final _publicRequest = Options(
    extra: {NetworkInterceptor.skipSessionKey: true},
  );

  Future<PhoneVerification> startPhoneVerification(String phone) async {
    final response = await _dio.post<Map<String, dynamic>>(
      _phoneVerifyPath,
      data: {'action': 'start', 'phone': phone},
      options: _publicRequest,
    );
    return PhoneVerification.fromJson(response.data!);
  }

  Future<PhoneVerificationResult> checkPhoneVerification(
    String sessionId,
  ) async {
    final response = await _dio.post<Map<String, dynamic>>(
      _phoneVerifyPath,
      data: {'action': 'status', 'session_id': sessionId},
      options: _publicRequest,
    );
    return PhoneVerificationResult.fromJson(response.data!);
  }

  Future<UserResponseData?> fetchProfile(String userId) async {
    final response = await _dio.get<List<dynamic>>(
      '/rest/v1/profiles',
      queryParameters: {
        'id': 'eq.$userId',
        'select': 'id,name,role,status,bank_name,bank_account_number,bank_account_holder,notifications_enabled,language',
      },
    );
    final rows = response.data!;
    if (rows.isEmpty) return null;
    return UserResponseData.fromJson(rows.first as Map<String, dynamic>);
  }

  Future<void> setMyName(String name) async {
    await _dio.post<dynamic>(
      '/rest/v1/rpc/set_my_name',
      data: {'p_name': name},
    );
  }

  Future<void> setPaymentAccount(
    String bank,
    String number,
    String holder,
  ) async {
    await _dio.post<dynamic>(
      '/rest/v1/rpc/set_my_payment_account',
      data: {'p_bank': bank, 'p_number': number, 'p_holder': holder},
    );
  }

  Future<void> setPreferences(
    bool notificationsEnabled,
    String language,
  ) async {
    await _dio.post<dynamic>(
      '/rest/v1/rpc/set_my_preferences',
      data: {
        'p_notifications_enabled': notificationsEnabled,
        'p_language': language,
      },
    );
  }

  Future<AuthSession> refresh(String refreshToken) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/auth/v1/token',
      queryParameters: {'grant_type': 'refresh_token'},
      data: {'refresh_token': refreshToken},
      options: _publicRequest,
    );
    return AuthSession.fromJson(response.data!);
  }

  Future<void> signOut() async {
    await _dio.post<dynamic>('/auth/v1/logout');
  }
}
