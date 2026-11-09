import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:hostel/connection/auth_api.dart';
import 'package:hostel/connection/model/auth_session.dart';
import 'package:hostel/connection/model/phone_verification.dart';
import 'package:hostel/connection/model/user_response_data.dart';
import 'package:hostel/shared/provider/session_store.dart';

enum AuthStatus { loading, signedOut, signedIn }

class AuthProvider extends ChangeNotifier {
  AuthProvider({
    required this._api,
    required this._store,
    DateTime Function()? now,
    Future<void> Function(Duration)? delay,
  }) : _now = now ?? DateTime.now,
       _delay = delay ?? Future<void>.delayed;

  // verify.mn asks for at least 3 seconds between status checks.
  static const _pollInterval = Duration(seconds: 3);
  static const _expiryGrace = Duration(seconds: 30);

  // The only automatic sign-out: the server says this login no longer exists,
  // so no request could ever succeed again. Everything else keeps the session.
  static const _deadSessionCodes = {
    'refresh_token_not_found',
    'refresh_token_already_used',
    'session_not_found',
    'session_expired',
    'user_not_found',
  };

  final AuthApi Function() _api;
  final SessionStore _store;
  final DateTime Function() _now;
  final Future<void> Function(Duration) _delay;

  AuthStatus _status = AuthStatus.loading;
  AuthSession? _session;
  UserResponseData? _user;
  Future<String?>? _refreshing;

  AuthStatus get status => _status;

  /// The resident's profile; null until loaded, or if loading failed.
  UserResponseData? get user => _user;

  Future<void> restore() async {
    _session = await _store.read();
    await _loadProfile();
    _publishStatus();
  }

  /// Runs a whole SMS verification and returns true only once the phone is
  /// confirmed, by which point the user is signed in.
  ///
  /// [onStarted] delivers the instruction and SMS link to show the resident.
  /// Returns false if the code expires or [isCancelled] becomes true, and
  /// throws if the verification can't be started at all.
  Future<bool> verifyPhone(
    String phone, {
    required void Function(PhoneVerification verification) onStarted,
    bool Function()? isCancelled,
  }) async {
    final verification = await _api().startPhoneVerification(phone);
    onStarted(verification);

    // A hard stop, in case the server can't be reached to report expiry.
    final deadline = verification.expiresAt.add(_expiryGrace);
    while (_now().isBefore(deadline)) {
      await _delay(_pollInterval);
      if (isCancelled?.call() ?? false) return false;
      try {
        final status = await _checkVerification(verification.sessionId);
        if (status == PhoneVerificationStatus.verified) return true;
        if (status == PhoneVerificationStatus.expired) return false;
      } on DioException {
        // A dropped connection shouldn't end the wait; the deadline will.
      }
    }
    return false;
  }

  Future<PhoneVerificationStatus> _checkVerification(String sessionId) async {
    final result = await _api().checkPhoneVerification(sessionId);
    final session = result.session;
    if (result.status == PhoneVerificationStatus.verified && session != null) {
      _session = session;
      await _saveSession(session);
      await _loadProfile();
      _publishStatus();
    }
    return result.status;
  }

  /// Throws if saving fails, so the sign-up screen can say so.
  Future<void> saveName(String name) async {
    await _api().setMyName(name);
    await refreshProfile();
  }

  Future<void> refreshProfile() async {
    await _loadProfile();
    notifyListeners();
  }

  Future<void> _loadProfile() async {
    final session = _session;
    if (session == null) return;
    try {
      _user = await _api().fetchProfile(session.user.id);
    } catch (_) {
      // Keep whatever we have and stay signed in: the server enforces access.
    }
  }

  /// Saving is best-effort. If storage fails the resident stays signed in
  /// until the app closes, which beats losing a login they paid 150₮ for.
  Future<void> _saveSession(AuthSession session) async {
    try {
      await _store.write(session);
    } catch (e) {
      _logStorageError(e);
    }
  }

  void _logStorageError(Object error) {
    final detail = error is PlatformException
        ? '${error.code} ${error.message}'
        : '${error.runtimeType}';
    debugPrint('[Auth] session storage failed: $detail');
  }

  void _publishStatus() {
    _status = _session == null ? AuthStatus.signedOut : AuthStatus.signedIn;
    notifyListeners();
  }

  /// A usable access token, refreshing first if it is about to expire.
  Future<String?> validAccessToken() async {
    final session = _session;
    if (session == null) return null;
    if (!session.isExpiringAt(_now())) return session.accessToken;
    // Concurrent requests share one refresh: refresh tokens are single-use.
    return _refreshing ??= _refresh(session).whenComplete(() {
      _refreshing = null;
    });
  }

  Future<String?> _refresh(AuthSession current) async {
    try {
      final fresh = await _api().refresh(current.refreshToken);
      // Signed out while the refresh was in flight: don't bring it back.
      if (!identical(_session, current)) return _session?.accessToken;
      _session = fresh;
      await _saveSession(fresh);
      return fresh.accessToken;
    } on DioException catch (e) {
      final data = e.response?.data;
      if (data is Map && _deadSessionCodes.contains(data['error_code'])) {
        clear();
        return null;
      }
      // Offline or server trouble: keep the session and let the call fail.
      return current.accessToken;
    }
  }

  Future<void> signOut() async {
    try {
      await _api().signOut();
    } on DioException {
      // Local sign-out must work even when the server can't be reached.
    }
    clear();
  }

  void clear() {
    if (_session == null && _status == AuthStatus.signedOut) return;
    _session = null;
    _user = null;
    _status = AuthStatus.signedOut;
    unawaited(_store.clear().catchError(_logStorageError));
    notifyListeners();
  }
}
